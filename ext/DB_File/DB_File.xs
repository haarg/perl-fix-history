/* 

 DB_File.xs -- Perl 5 interface to Berkeley DB 

 written by Paul Marquess <Paul.Marquess@btinternet.com>
 last modified 6th March 1999
 version 1.66

 All comments/suggestions/problems are welcome

     Copyright (c) 1995-9 Paul Marquess. All rights reserved.
     This program is free software; you can redistribute it and/or
     modify it under the same terms as Perl itself.

 Changes:
	0.1 - 	Initial Release
	0.2 - 	No longer bombs out if dbopen returns an error.
	0.3 - 	Added some support for multiple btree compares
	1.0 - 	Complete support for multiple callbacks added.
	      	Fixed a problem with pushing a value onto an empty list.
	1.01 - 	Fixed a SunOS core dump problem.
		The return value from TIEHASH wasn't set to NULL when
		dbopen returned an error.
	1.02 - 	Use ALIAS to define TIEARRAY.
		Removed some redundant commented code.
		Merged OS2 code into the main distribution.
		Allow negative subscripts with RECNO interface.
		Changed the default flags to O_CREAT|O_RDWR
	1.03 - 	Added EXISTS
	1.04 -  fixed a couple of bugs in hash_cb. Patches supplied by
		Dave Hammen, hammen@gothamcity.jsc.nasa.gov
	1.05 -  Added logic to allow prefix & hash types to be specified via
		Makefile.PL
	1.06 -  Minor namespace cleanup: Localized PrintBtree.
	1.07 -  Fixed bug with RECNO, where bval wasn't defaulting to "\n". 
	1.08 -  No change to DB_File.xs
	1.09 -  Default mode for dbopen changed to 0666
	1.10 -  Fixed fd method so that it still returns -1 for
		in-memory files when db 1.86 is used.
	1.11 -  No change to DB_File.xs
	1.12 -  No change to DB_File.xs
	1.13 -  Tidied up a few casts.     
	1.14 -	Made it illegal to tie an associative array to a RECNO
		database and an ordinary array to a HASH or BTREE database.
	1.50 -  Make work with both DB 1.x or DB 2.x
	1.51 -  Fixed a bug in mapping 1.x O_RDONLY flag to 2.x DB_RDONLY equivalent
	1.52 -  Patch from Gisle Aas <gisle@aas.no> to suppress "use of 
		undefined value" warning with db_get and db_seq.
	1.53 -  Added DB_RENUMBER to flags for recno.
	1.54 -  Fixed bug in the fd method
        1.55 -  Fix for AIX from Jarkko Hietaniemi
        1.56 -  No change to DB_File.xs
        1.57 -  added the #undef op to allow building with Threads support.
	1.58 -  Fixed a problem with the use of sv_setpvn. When the
		size is specified as 0, it does a strlen on the data.
		This was ok for DB 1.x, but isn't for DB 2.x.
        1.59 -  No change to DB_File.xs
        1.60 -  Some code tidy up
        1.61 -  added flagSet macro for DB 2.5.x
		fixed typo in O_RDONLY test.
        1.62 -  No change to DB_File.xs
        1.63 -  Fix to alllow DB 2.6.x to build.
        1.64 -  Tidied up the 1.x to 2.x flags mapping code.
		Added a patch from Mark Kettenis <kettenis@wins.uva.nl>
		to fix a flag mapping problem with O_RDONLY on the Hurd
        1.65 -  Fixed a bug in the PUSH logic.
		Added BOOT check that using 2.3.4 or greater
        1.66 -  Added DBM filter code



*/

#include "EXTERN.h"  
#include "perl.h"
#include "XSUB.h"

#ifndef PERL_VERSION
#include "patchlevel.h"
#define PERL_REVISION	5
#define PERL_VERSION	PATCHLEVEL
#define PERL_SUBVERSION	SUBVERSION
#endif

#if PERL_REVISION == 5 && (PERL_VERSION < 4 || (PERL_VERSION == 4 && PERL_SUBVERSION <= 75 ))

#    define PL_sv_undef		sv_undef
#    define PL_na		na

#endif

/* Being the Berkeley DB we prefer the <sys/cdefs.h> (which will be
 * shortly #included by the <db.h>) __attribute__ to the possibly
 * already defined __attribute__, for example by GNUC or by Perl. */

#undef __attribute__

/* If Perl has been compiled with Threads support,the symbol op will
   be defined here. This clashes with a field name in db.h, so get rid of it.
 */
#ifdef op
#undef op
#endif
#include <db.h>

#include <fcntl.h> 

/* #define TRACE */
#define DBM_FILTERING



#ifdef DB_VERSION_MAJOR

/* map version 2 features & constants onto their version 1 equivalent */

#ifdef DB_Prefix_t
#undef DB_Prefix_t
#endif
#define DB_Prefix_t	size_t

#ifdef DB_Hash_t
#undef DB_Hash_t
#endif
#define DB_Hash_t	u_int32_t

/* DBTYPE stays the same */
/* HASHINFO, RECNOINFO and BTREEINFO  map to DB_INFO */
typedef DB_INFO	INFO ;

/* version 2 has db_recno_t in place of recno_t	*/
typedef db_recno_t	recno_t;


#define R_CURSOR        DB_SET_RANGE
#define R_FIRST         DB_FIRST
#define R_IAFTER        DB_AFTER
#define R_IBEFORE       DB_BEFORE
#define R_LAST          DB_LAST
#define R_NEXT          DB_NEXT
#define R_NOOVERWRITE   DB_NOOVERWRITE
#define R_PREV          DB_PREV
#define R_SETCURSOR     0
#define R_RECNOSYNC     0
#define R_FIXEDLEN	DB_FIXEDLEN
#define R_DUP		DB_DUP

#define db_HA_hash 	h_hash
#define db_HA_ffactor	h_ffactor
#define db_HA_nelem	h_nelem
#define db_HA_bsize	db_pagesize
#define db_HA_cachesize	db_cachesize
#define db_HA_lorder	db_lorder

#define db_BT_compare	bt_compare
#define db_BT_prefix	bt_prefix
#define db_BT_flags	flags
#define db_BT_psize	db_pagesize
#define db_BT_cachesize	db_cachesize
#define db_BT_lorder	db_lorder
#define db_BT_maxkeypage
#define db_BT_minkeypage


#define db_RE_reclen	re_len
#define db_RE_flags	flags
#define db_RE_bval	re_pad
#define db_RE_bfname	re_source
#define db_RE_psize	db_pagesize
#define db_RE_cachesize	db_cachesize
#define db_RE_lorder	db_lorder

#define TXN	NULL,

#define do_SEQ(db, key, value, flag)	(db->cursor->c_get)(db->cursor, &key, &value, flag)


#define DBT_flags(x)	x.flags = 0
#define DB_flags(x, v)	x |= v 

#if DB_VERSION_MAJOR == 2 && DB_VERSION_MINOR < 5
#define flagSet(flags, bitmask)        ((flags) & (bitmask))
#else
#define flagSet(flags, bitmask)        (((flags) & DB_OPFLAGS_MASK) == (bitmask))
#endif

#else /* db version 1.x */

typedef union INFO {
        HASHINFO 	hash ;
        RECNOINFO 	recno ;
        BTREEINFO 	btree ;
      } INFO ;


#ifdef mDB_Prefix_t 
#ifdef DB_Prefix_t
#undef DB_Prefix_t
#endif
#define DB_Prefix_t	mDB_Prefix_t 
#endif

#ifdef mDB_Hash_t
#ifdef DB_Hash_t
#undef DB_Hash_t
#endif
#define DB_Hash_t	mDB_Hash_t
#endif

#define db_HA_hash 	hash.hash
#define db_HA_ffactor	hash.ffactor
#define db_HA_nelem	hash.nelem
#define db_HA_bsize	hash.bsize
#define db_HA_cachesize	hash.cachesize
#define db_HA_lorder	hash.lorder

#define db_BT_compare	btree.compare
#define db_BT_prefix	btree.prefix
#define db_BT_flags	btree.flags
#define db_BT_psize	btree.psize
#define db_BT_cachesize	btree.cachesize
#define db_BT_lorder	btree.lorder
#define db_BT_maxkeypage btree.maxkeypage
#define db_BT_minkeypage btree.minkeypage

#define db_RE_reclen	recno.reclen
#define db_RE_flags	recno.flags
#define db_RE_bval	recno.bval
#define db_RE_bfname	recno.bfname
#define db_RE_psize	recno.psize
#define db_RE_cachesize	recno.cachesize
#define db_RE_lorder	recno.lorder

#define TXN	

#define do_SEQ(db, key, value, flag)	(db->dbp->seq)(db->dbp, &key, &value, flag)
#define DBT_flags(x)	
#define DB_flags(x, v)	
#define flagSet(flags, bitmask)        ((flags) & (bitmask))

#endif /* db version 1 */



#define db_DELETE(db, key, flags)       ((db->dbp)->del)(db->dbp, TXN &key, flags)
#define db_STORE(db, key, value, flags) ((db->dbp)->put)(db->dbp, TXN &key, &value, flags)
#define db_FETCH(db, key, flags)        ((db->dbp)->get)(db->dbp, TXN &key, &value, flags)

#define db_sync(db, flags)              ((db->dbp)->sync)(db->dbp, flags)
#define db_get(db, key, value, flags)   ((db->dbp)->get)(db->dbp, TXN &key, &value, flags)

#ifdef DB_VERSION_MAJOR
#define db_DESTROY(db)                  ((db->dbp)->close)(db->dbp, 0)
#define db_close(db)			((db->dbp)->close)(db->dbp, 0)
#define db_del(db, key, flags)          (flagSet(flags, R_CURSOR) 					\
						? ((db->cursor)->c_del)(db->cursor, 0)		\
						: ((db->dbp)->del)(db->dbp, NULL, &key, flags) )

#else

#define db_DESTROY(db)                  ((db->dbp)->close)(db->dbp)
#define db_close(db)			((db->dbp)->close)(db->dbp)
#define db_del(db, key, flags)          ((db->dbp)->del)(db->dbp, &key, flags)
#define db_put(db, key, value, flags)   ((db->dbp)->put)(db->dbp, &key, &value, flags)

#endif


#define db_seq(db, key, value, flags)   do_SEQ(db, key, value, flags)

typedef struct {
	DBTYPE	type ;
	DB * 	dbp ;
	SV *	compare ;
	SV *	prefix ;
	SV *	hash ;
	int	in_memory ;
	INFO 	info ;
#ifdef DB_VERSION_MAJOR
	DBC *	cursor ;
#endif
#ifdef DBM_FILTERING
	SV *    filter_fetch_key ;
	SV *    filter_store_key ;
	SV *    filter_fetch_value ;
	SV *    filter_store_value ;
	int     filtering ;
#endif /* DBM_FILTERING */

	} DB_File_type;

typedef DB_File_type * DB_File ;
typedef DBT DBTKEY ;

#ifdef DBM_FILTERING

#define ckFilter(arg,type,name)					\
	if (db->type) {						\
	    SV * save_defsv ;					\
            /* printf("filtering %s\n", name) ;*/		\
	    if (db->filtering)					\
	        croak("recursion detected in %s", name) ;	\
	    db->filtering = TRUE ;				\
	    /* SAVE_DEFSV ;*/   /* save $_ */			\
	    save_defsv = newSVsv(DEFSV) ;			\
	    sv_setsv(DEFSV, arg) ;				\
	    PUSHMARK(sp) ;					\
	    (void) perl_call_sv(db->type, G_DISCARD|G_NOARGS); 	\
	    /* SPAGAIN ; */						\
	    sv_setsv(arg, DEFSV) ;				\
	    sv_setsv(DEFSV, save_defsv) ;				\
	    SvREFCNT_dec(save_defsv) ;				\
	    /* PUTBACK ; */						\
	    db->filtering = FALSE ;				\
	    /*printf("end of filtering %s\n", name) ;*/		\
	}

#else

#define ckFilter(arg,type, name)

#endif /* DBM_FILTERING */

#define my_sv_setpvn(sv, d, s) sv_setpvn(sv, (s ? d : (void*)""), s)

#define OutputValue(arg, name)  					\
	{ if (RETVAL == 0) {						\
	      my_sv_setpvn(arg, name.data, name.size) ;			\
	      ckFilter(arg, filter_fetch_value,"filter_fetch_value") ; 	\
	  }								\
	}

#define OutputKey(arg, name)	 					\
	{ if (RETVAL == 0) 						\
	  { 								\
		if (db->type != DB_RECNO) {				\
		    my_sv_setpvn(arg, name.data, name.size); 		\
		}							\
		else 							\
		    sv_setiv(arg, (I32)*(I32*)name.data - 1); 		\
	      ckFilter(arg, filter_fetch_key,"filter_fetch_key") ; 	\
	  } 								\
	}


/* Internal Global Data */
static recno_t Value ; 
static recno_t zero = 0 ;
static DB_File CurrentDB ;
static DBTKEY empty ;

#ifdef DB_VERSION_MAJOR

static int
db_put(DB_File db, DBTKEY key, DBT value, u_int flags)
{
    int status ;

    if (flagSet(flags, R_CURSOR)) {
	status = ((db->cursor)->c_del)(db->cursor, 0);
	if (status != 0)
	    return status ;

#if DB_VERSION_MAJOR == 2 && DB_VERSION_MINOR < 5
	flags &= ~R_CURSOR ;
#else
	flags &= ~DB_OPFLAGS_MASK ;
#endif

    }

    return ((db->dbp)->put)(db->dbp, NULL, &key, &value, flags) ;

}

#endif /* DB_VERSION_MAJOR */

static void
GetVersionInfo(pTHX)
{
    SV * ver_sv = perl_get_sv("DB_File::db_version", TRUE) ;
#ifdef DB_VERSION_MAJOR
    int Major, Minor, Patch ;

    (void)db_version(&Major, &Minor, &Patch) ;

    /* check that libdb is recent enough  -- we need 2.3.4 or greater */
    if (Major == 2 && (Minor < 3 || (Minor ==  3 && Patch < 4)))
	croak("DB_File needs Berkeley DB 2.3.4 or greater, you have %d.%d.%d\n",
		 Major, Minor, Patch) ;
 
#if PERL_VERSION > 3
    sv_setpvf(ver_sv, "%d.%d", Major, Minor) ;
#else
    {
        char buffer[40] ;
        sprintf(buffer, "%d.%d", Major, Minor) ;
        sv_setpv(ver_sv, buffer) ; 
    }
#endif
 
#else
    sv_setiv(ver_sv, 1) ;
#endif

}


static int
btree_compare(const DBT *key1, const DBT *key2)
{
    dTHX;
    dSP ;
    void * data1, * data2 ;
    int retval ;
    int count ;
    
    data1 = key1->data ;
    data2 = key2->data ;
#if 0
    /* As newSVpv will assume that the data pointer is a null terminated C 
       string if the size parameter is 0, make sure that data points to an 
       empty string if the length is 0
    */
    if (key1->size == 0)
        data1 = "" ; 
    if (key2->size == 0)
        data2 = "" ;
#endif
    ENTER ;
    SAVETMPS;

    PUSHMARK(SP) ;
    EXTEND(SP,2) ;
    PUSHs(sv_2mortal(newSVpvn(data1,key1->size)));
    PUSHs(sv_2mortal(newSVpvn(data2,key2->size)));
    PUTBACK ;

    count = perl_call_sv(CurrentDB->compare, G_SCALAR); 

    SPAGAIN ;

    if (count != 1)
        croak ("DB_File btree_compare: expected 1 return value from compare sub, got %d\n", count) ;

    retval = POPi ;

    PUTBACK ;
    FREETMPS ;
    LEAVE ;
    return (retval) ;

}

static DB_Prefix_t
btree_prefix(const DBT *key1, const DBT *key2)
{
    dTHX;
    dSP ;
    void * data1, * data2 ;
    int retval ;
    int count ;
    
    data1 = key1->data ;
    data2 = key2->data ;
#if 0
    /* As newSVpv will assume that the data pointer is a null terminated C 
       string if the size parameter is 0, make sure that data points to an 
       empty string if the length is 0
    */
    if (key1->size == 0)
        data1 = "" ;
    if (key2->size == 0)
        data2 = "" ;
#endif
    ENTER ;
    SAVETMPS;

    PUSHMARK(SP) ;
    EXTEND(SP,2) ;
    PUSHs(sv_2mortal(newSVpvn(data1,key1->size)));
    PUSHs(sv_2mortal(newSVpvn(data2,key2->size)));
    PUTBACK ;

    count = perl_call_sv(CurrentDB->prefix, G_SCALAR); 

    SPAGAIN ;

    if (count != 1)
        croak ("DB_File btree_prefix: expected 1 return value from prefix sub, got %d\n", count) ;
 
    retval = POPi ;
 
    PUTBACK ;
    FREETMPS ;
    LEAVE ;

    return (retval) ;
}

static DB_Hash_t
hash_cb(const void *data, size_t size)
{
    dTHX;
    dSP ;
    int retval ;
    int count ;
#if 0
    if (size == 0)
        data = "" ;
#endif
     /* DGH - Next two lines added to fix corrupted stack problem */
    ENTER ;
    SAVETMPS;

    PUSHMARK(SP) ;

    XPUSHs(sv_2mortal(newSVpvn((char*)data,size)));
    PUTBACK ;

    count = perl_call_sv(CurrentDB->hash, G_SCALAR); 

    SPAGAIN ;

    if (count != 1)
        croak ("DB_File hash_cb: expected 1 return value from hash sub, got %d\n", count) ;

    retval = POPi ;

    PUTBACK ;
    FREETMPS ;
    LEAVE ;

    return (retval) ;
}


#ifdef TRACE

static void
PrintHash(INFO *hash)
{
    printf ("HASH Info\n") ;
    printf ("  hash      = %s\n", 
		(hash->db_HA_hash != NULL ? "redefined" : "default")) ;
    printf ("  bsize     = %d\n", hash->db_HA_bsize) ;
    printf ("  ffactor   = %d\n", hash->db_HA_ffactor) ;
    printf ("  nelem     = %d\n", hash->db_HA_nelem) ;
    printf ("  cachesize = %d\n", hash->db_HA_cachesize) ;
    printf ("  lorder    = %d\n", hash->db_HA_lorder) ;

}

static void
PrintRecno(INFO *recno)
{
    printf ("RECNO Info\n") ;
    printf ("  flags     = %d\n", recno->db_RE_flags) ;
    printf ("  cachesize = %d\n", recno->db_RE_cachesize) ;
    printf ("  psize     = %d\n", recno->db_RE_psize) ;
    printf ("  lorder    = %d\n", recno->db_RE_lorder) ;
    printf ("  reclen    = %ul\n", (unsigned long)recno->db_RE_reclen) ;
    printf ("  bval      = %d 0x%x\n", recno->db_RE_bval, recno->db_RE_bval) ;
    printf ("  bfname    = %d [%s]\n", recno->db_RE_bfname, recno->db_RE_bfname) ;
}

static void
PrintBtree(INFO *btree)
{
    printf ("BTREE Info\n") ;
    printf ("  compare    = %s\n", 
		(btree->db_BT_compare ? "redefined" : "default")) ;
    printf ("  prefix     = %s\n", 
		(btree->db_BT_prefix ? "redefined" : "default")) ;
    printf ("  flags      = %d\n", btree->db_BT_flags) ;
    printf ("  cachesize  = %d\n", btree->db_BT_cachesize) ;
    printf ("  psize      = %d\n", btree->db_BT_psize) ;
#ifndef DB_VERSION_MAJOR
    printf ("  maxkeypage = %d\n", btree->db_BT_maxkeypage) ;
    printf ("  minkeypage = %d\n", btree->db_BT_minkeypage) ;
#endif
    printf ("  lorder     = %d\n", btree->db_BT_lorder) ;
}

#else

#define PrintRecno(recno)
#define PrintHash(hash)
#define PrintBtree(btree)

#endif /* TRACE */


static I32
GetArrayLength(pTHX_ DB_File db)
{
    DBT		key ;
    DBT		value ;
    int		RETVAL ;

    DBT_flags(key) ;
    DBT_flags(value) ;
    RETVAL = do_SEQ(db, key, value, R_LAST) ;
    if (RETVAL == 0)
        RETVAL = *(I32 *)key.data ;
    else /* No key means empty file */
        RETVAL = 0 ;

    return ((I32)RETVAL) ;
}

static recno_t
GetRecnoKey(pTHX_ DB_File db, I32 value)
{
    if (value < 0) {
	/* Get the length of the array */
	I32 length = GetArrayLength(aTHX_ db) ;

	/* check for attempt to write before start of array */
	if (length + value + 1 <= 0)
	    croak("Modification of non-creatable array value attempted, subscript %ld", (long)value) ;

	value = length + value + 1 ;
    }
    else
        ++ value ;

    return value ;
}

static DB_File
ParseOpenInfo(pTHX_ int isHASH, char *name, int flags, int mode, SV *sv)
{
    SV **	svp;
    HV *	action ;
    DB_File	RETVAL = (DB_File)safemalloc(sizeof(DB_File_type)) ;
    void *	openinfo = NULL ;
    INFO	* info  = &RETVAL->info ;
    STRLEN	n_a;

/* printf("In ParseOpenInfo name=[%s] flags=[%d] mode = [%d]\n", name, flags, mode) ;  */
    Zero(RETVAL, 1, DB_File_type) ;

    /* Default to HASH */
#ifdef DBM_FILTERING
    RETVAL->filtering = 0 ;
    RETVAL->filter_fetch_key = RETVAL->filter_store_key = 
    RETVAL->filter_fetch_value = RETVAL->filter_store_value =
#endif /* DBM_FILTERING */
    RETVAL->hash = RETVAL->compare = RETVAL->prefix = NULL ;
    RETVAL->type = DB_HASH ;

     /* DGH - Next line added to avoid SEGV on existing hash DB */
    CurrentDB = RETVAL; 

    /* fd for 1.86 hash in memory files doesn't return -1 like 1.85 */
    RETVAL->in_memory = (name == NULL) ;

    if (sv)
    {
        if (! SvROK(sv) )
            croak ("type parameter is not a reference") ;

        svp  = hv_fetch( (HV*)SvRV(sv), "GOT", 3, FALSE) ;
        if (svp && SvOK(*svp))
            action  = (HV*) SvRV(*svp) ;
	else
	    croak("internal error") ;

        if (sv_isa(sv, "DB_File::HASHINFO"))
        {

	    if (!isHASH)
	        croak("DB_File can only tie an associative array to a DB_HASH database") ;

            RETVAL->type = DB_HASH ;
            openinfo = (void*)info ;
  
            svp = hv_fetch(action, "hash", 4, FALSE); 

            if (svp && SvOK(*svp))
            {
                info->db_HA_hash = hash_cb ;
		RETVAL->hash = newSVsv(*svp) ;
            }
            else
	        info->db_HA_hash = NULL ;

           svp = hv_fetch(action, "ffactor", 7, FALSE);
           info->db_HA_ffactor = svp ? SvIV(*svp) : 0;
         
           svp = hv_fetch(action, "nelem", 5, FALSE);
           info->db_HA_nelem = svp ? SvIV(*svp) : 0;
         
           svp = hv_fetch(action, "bsize", 5, FALSE);
           info->db_HA_bsize = svp ? SvIV(*svp) : 0;
           
           svp = hv_fetch(action, "cachesize", 9, FALSE);
           info->db_HA_cachesize = svp ? SvIV(*svp) : 0;
         
           svp = hv_fetch(action, "lorder", 6, FALSE);
           info->db_HA_lorder = svp ? SvIV(*svp) : 0;

           PrintHash(info) ; 
        }
        else if (sv_isa(sv, "DB_File::BTREEINFO"))
        {
	    if (!isHASH)
	        croak("DB_File can only tie an associative array to a DB_BTREE database");

            RETVAL->type = DB_BTREE ;
            openinfo = (void*)info ;
   
            svp = hv_fetch(action, "compare", 7, FALSE);
            if (svp && SvOK(*svp))
            {
                info->db_BT_compare = btree_compare ;
		RETVAL->compare = newSVsv(*svp) ;
            }
            else
                info->db_BT_compare = NULL ;

            svp = hv_fetch(action, "prefix", 6, FALSE);
            if (svp && SvOK(*svp))
            {
                info->db_BT_prefix = btree_prefix ;
		RETVAL->prefix = newSVsv(*svp) ;
            }
            else
                info->db_BT_prefix = NULL ;

            svp = hv_fetch(action, "flags", 5, FALSE);
            info->db_BT_flags = svp ? SvIV(*svp) : 0;
   
            svp = hv_fetch(action, "cachesize", 9, FALSE);
            info->db_BT_cachesize = svp ? SvIV(*svp) : 0;
         
#ifndef DB_VERSION_MAJOR
            svp = hv_fetch(action, "minkeypage", 10, FALSE);
            info->btree.minkeypage = svp ? SvIV(*svp) : 0;
        
            svp = hv_fetch(action, "maxkeypage", 10, FALSE);
            info->btree.maxkeypage = svp ? SvIV(*svp) : 0;
#endif

            svp = hv_fetch(action, "psize", 5, FALSE);
            info->db_BT_psize = svp ? SvIV(*svp) : 0;
         
            svp = hv_fetch(action, "lorder", 6, FALSE);
            info->db_BT_lorder = svp ? SvIV(*svp) : 0;

            PrintBtree(info) ;
         
        }
        else if (sv_isa(sv, "DB_File::RECNOINFO"))
        {
	    if (isHASH)
	        croak("DB_File can only tie an array to a DB_RECNO database");

            RETVAL->type = DB_RECNO ;
            openinfo = (void *)info ;

	    info->db_RE_flags = 0 ;

            svp = hv_fetch(action, "flags", 5, FALSE);
            info->db_RE_flags = (u_long) (svp ? SvIV(*svp) : 0);
         
            svp = hv_fetch(action, "reclen", 6, FALSE);
            info->db_RE_reclen = (size_t) (svp ? SvIV(*svp) : 0);
         
            svp = hv_fetch(action, "cachesize", 9, FALSE);
            info->db_RE_cachesize = (u_int) (svp ? SvIV(*svp) : 0);
         
            svp = hv_fetch(action, "psize", 5, FALSE);
            info->db_RE_psize = (u_int) (svp ? SvIV(*svp) : 0);
         
            svp = hv_fetch(action, "lorder", 6, FALSE);
            info->db_RE_lorder = (int) (svp ? SvIV(*svp) : 0);

#ifdef DB_VERSION_MAJOR
	    info->re_source = name ;
	    name = NULL ;
#endif
            svp = hv_fetch(action, "bfname", 6, FALSE); 
            if (svp && SvOK(*svp)) {
		char * ptr = SvPV(*svp,n_a) ;
#ifdef DB_VERSION_MAJOR
		name = (char*) n_a ? ptr : NULL ;
#else
                info->db_RE_bfname = (char*) (n_a ? ptr : NULL) ;
#endif
	    }
	    else
#ifdef DB_VERSION_MAJOR
		name = NULL ;
#else
                info->db_RE_bfname = NULL ;
#endif
         
	    svp = hv_fetch(action, "bval", 4, FALSE);
#ifdef DB_VERSION_MAJOR
            if (svp && SvOK(*svp))
            {
		int value ;
                if (SvPOK(*svp))
		    value = (int)*SvPV(*svp, n_a) ;
		else
		    value = SvIV(*svp) ;

		if (info->flags & DB_FIXEDLEN) {
		    info->re_pad = value ;
		    info->flags |= DB_PAD ;
		}
		else {
		    info->re_delim = value ;
		    info->flags |= DB_DELIMITER ;
		}

            }
#else
            if (svp && SvOK(*svp))
            {
                if (SvPOK(*svp))
		    info->db_RE_bval = (u_char)*SvPV(*svp, n_a) ;
		else
		    info->db_RE_bval = (u_char)(unsigned long) SvIV(*svp) ;
		DB_flags(info->flags, DB_DELIMITER) ;

            }
            else
 	    {
		if (info->db_RE_flags & R_FIXEDLEN)
                    info->db_RE_bval = (u_char) ' ' ;
		else
                    info->db_RE_bval = (u_char) '\n' ;
		DB_flags(info->flags, DB_DELIMITER) ;
	    }
#endif

#ifdef DB_RENUMBER
	    info->flags |= DB_RENUMBER ;
#endif
         
            PrintRecno(info) ;
        }
        else
            croak("type is not of type DB_File::HASHINFO, DB_File::BTREEINFO or DB_File::RECNOINFO");
    }


    /* OS2 Specific Code */
#ifdef OS2
#ifdef __EMX__
    flags |= O_BINARY;
#endif /* __EMX__ */
#endif /* OS2 */

#ifdef DB_VERSION_MAJOR

    {
        int	 	Flags = 0 ;
        int		status ;

        /* Map 1.x flags to 2.x flags */
        if ((flags & O_CREAT) == O_CREAT)
            Flags |= DB_CREATE ;

#if O_RDONLY == 0
        if (flags == O_RDONLY)
#else
        if ((flags & O_RDONLY) == O_RDONLY && (flags & O_RDWR) != O_RDWR)
#endif
            Flags |= DB_RDONLY ;

#ifdef O_TRUNC
        if ((flags & O_TRUNC) == O_TRUNC)
            Flags |= DB_TRUNCATE ;
#endif

        status = db_open(name, RETVAL->type, Flags, mode, NULL, openinfo, &RETVAL->dbp) ; 
        if (status == 0)
#if DB_VERSION_MAJOR == 2 && DB_VERSION_MINOR < 6
            status = (RETVAL->dbp->cursor)(RETVAL->dbp, NULL, &RETVAL->cursor) ;
#else
            status = (RETVAL->dbp->cursor)(RETVAL->dbp, NULL, &RETVAL->cursor,
			0) ;
#endif

        if (status)
	    RETVAL->dbp = NULL ;

    }
#else
    RETVAL->dbp = dbopen(name, flags, mode, RETVAL->type, openinfo) ; 
#endif

    return (RETVAL) ;
}


static double 
constant(char *name, int arg)
{
    errno = 0;
    switch (*name) {
    case 'A':
	break;
    case 'B':
	if (strEQ(name, "BTREEMAGIC"))
#ifdef BTREEMAGIC
	    return BTREEMAGIC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "BTREEVERSION"))
#ifdef BTREEVERSION
	    return BTREEVERSION;
#else
	    goto not_there;
#endif
	break;
    case 'C':
	break;
    case 'D':
	if (strEQ(name, "DB_LOCK"))
#ifdef DB_LOCK
	    return DB_LOCK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "DB_SHMEM"))
#ifdef DB_SHMEM
	    return DB_SHMEM;
#else
	    goto not_there;
#endif
	if (strEQ(name, "DB_TXN"))
#ifdef DB_TXN
	    return (U32)DB_TXN;
#else
	    goto not_there;
#endif
	break;
    case 'E':
	break;
    case 'F':
	break;
    case 'G':
	break;
    case 'H':
	if (strEQ(name, "HASHMAGIC"))
#ifdef HASHMAGIC
	    return HASHMAGIC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "HASHVERSION"))
#ifdef HASHVERSION
	    return HASHVERSION;
#else
	    goto not_there;
#endif
	break;
    case 'I':
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	if (strEQ(name, "MAX_PAGE_NUMBER"))
#ifdef MAX_PAGE_NUMBER
	    return (U32)MAX_PAGE_NUMBER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_PAGE_OFFSET"))
#ifdef MAX_PAGE_OFFSET
	    return MAX_PAGE_OFFSET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "MAX_REC_NUMBER"))
#ifdef MAX_REC_NUMBER
	    return (U32)MAX_REC_NUMBER;
#else
	    goto not_there;
#endif
	break;
    case 'N':
	break;
    case 'O':
	break;
    case 'P':
	break;
    case 'Q':
	break;
    case 'R':
	if (strEQ(name, "RET_ERROR"))
#ifdef RET_ERROR
	    return RET_ERROR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RET_SPECIAL"))
#ifdef RET_SPECIAL
	    return RET_SPECIAL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "RET_SUCCESS"))
#ifdef RET_SUCCESS
	    return RET_SUCCESS;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_CURSOR"))
#ifdef R_CURSOR
	    return R_CURSOR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_DUP"))
#ifdef R_DUP
	    return R_DUP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_FIRST"))
#ifdef R_FIRST
	    return R_FIRST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_FIXEDLEN"))
#ifdef R_FIXEDLEN
	    return R_FIXEDLEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_IAFTER"))
#ifdef R_IAFTER
	    return R_IAFTER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_IBEFORE"))
#ifdef R_IBEFORE
	    return R_IBEFORE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_LAST"))
#ifdef R_LAST
	    return R_LAST;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NEXT"))
#ifdef R_NEXT
	    return R_NEXT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NOKEY"))
#ifdef R_NOKEY
	    return R_NOKEY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_NOOVERWRITE"))
#ifdef R_NOOVERWRITE
	    return R_NOOVERWRITE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_PREV"))
#ifdef R_PREV
	    return R_PREV;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_RECNOSYNC"))
#ifdef R_RECNOSYNC
	    return R_RECNOSYNC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_SETCURSOR"))
#ifdef R_SETCURSOR
	    return R_SETCURSOR;
#else
	    goto not_there;
#endif
	if (strEQ(name, "R_SNAPSHOT"))
#ifdef R_SNAPSHOT
	    return R_SNAPSHOT;
#else
	    goto not_there;
#endif
	break;
    case 'S':
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    case '_':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

MODULE = DB_File	PACKAGE = DB_File	PREFIX = db_

BOOT:
  {
    GetVersionInfo(aTHX) ;
 
    empty.data = &zero ;
    empty.size =  sizeof(recno_t) ;
    DBT_flags(empty) ; 
  }

double
constant(name,arg)
	char *		name
	int		arg


DB_File
db_DoTie_(isHASH, dbtype, name=undef, flags=O_CREAT|O_RDWR, mode=0666, type=DB_HASH)
	int		isHASH
	char *		dbtype
	int		flags
	int		mode
	CODE:
	{
	    char *	name = (char *) NULL ; 
	    SV *	sv = (SV *) NULL ; 
	    STRLEN	n_a;

	    if (items >= 3 && SvOK(ST(2))) 
	        name = (char*) SvPV(ST(2), n_a) ; 

            if (items == 6)
	        sv = ST(5) ;

	    RETVAL = ParseOpenInfo(aTHX_ isHASH, name, flags, mode, sv) ;
	    if (RETVAL->dbp == NULL)
	        RETVAL = NULL ;
	}
	OUTPUT:	
	    RETVAL

int
db_DESTROY(db)
	DB_File		db
	INIT:
	  CurrentDB = db ;
	CLEANUP:
	  if (db->hash)
	    SvREFCNT_dec(db->hash) ;
	  if (db->compare)
	    SvREFCNT_dec(db->compare) ;
	  if (db->prefix)
	    SvREFCNT_dec(db->prefix) ;
#ifdef DBM_FILTERING
	  if (db->filter_fetch_key)
	    SvREFCNT_dec(db->filter_fetch_key) ;
	  if (db->filter_store_key)
	    SvREFCNT_dec(db->filter_store_key) ;
	  if (db->filter_fetch_value)
	    SvREFCNT_dec(db->filter_fetch_value) ;
	  if (db->filter_store_value)
	    SvREFCNT_dec(db->filter_store_value) ;
#endif /* DBM_FILTERING */
	  Safefree(db) ;
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
#endif


int
db_DELETE(db, key, flags=0)
	DB_File		db
	DBTKEY		key
	u_int		flags
	INIT:
	  CurrentDB = db ;


int
db_EXISTS(db, key)
	DB_File		db
	DBTKEY		key
	CODE:
	{
          DBT		value ;
	
	  DBT_flags(value) ; 
	  CurrentDB = db ;
	  RETVAL = (((db->dbp)->get)(db->dbp, TXN &key, &value, 0) == 0) ;
	}
	OUTPUT:
	  RETVAL

int
db_FETCH(db, key, flags=0)
	DB_File		db
	DBTKEY		key
	u_int		flags
	CODE:
	{
            DBT		value ;

	    DBT_flags(value) ; 
	    CurrentDB = db ;
	    /* RETVAL = ((db->dbp)->get)(db->dbp, TXN &key, &value, flags) ; */
	    RETVAL = db_get(db, key, value, flags) ;
	    ST(0) = sv_newmortal();
	    OutputValue(ST(0), value)
	}

int
db_STORE(db, key, value, flags=0)
	DB_File		db
	DBTKEY		key
	DBT		value
	u_int		flags
	INIT:
	  CurrentDB = db ;


int
db_FIRSTKEY(db)
	DB_File		db
	CODE:
	{
	    DBTKEY	key ;
	    DBT		value ;

	    DBT_flags(key) ; 
	    DBT_flags(value) ; 
	    CurrentDB = db ;
	    RETVAL = do_SEQ(db, key, value, R_FIRST) ;
	    ST(0) = sv_newmortal();
	    OutputKey(ST(0), key) ;
	}

int
db_NEXTKEY(db, key)
	DB_File		db
	DBTKEY		key
	CODE:
	{
	    DBT		value ;

	    DBT_flags(value) ; 
	    CurrentDB = db ;
	    RETVAL = do_SEQ(db, key, value, R_NEXT) ;
	    ST(0) = sv_newmortal();
	    OutputKey(ST(0), key) ;
	}

#
# These would be nice for RECNO
#

int
unshift(db, ...)
	DB_File		db
	ALIAS:		UNSHIFT = 1
	CODE:
	{
	    DBTKEY	key ;
	    DBT		value ;
	    int		i ;
	    int		One ;
	    DB *	Db = db->dbp ;
	    STRLEN	n_a;

	    DBT_flags(key) ; 
	    DBT_flags(value) ; 
	    CurrentDB = db ;
#ifdef DB_VERSION_MAJOR
	    /* get the first value */
	    RETVAL = do_SEQ(db, key, value, DB_FIRST) ;	 
	    RETVAL = 0 ;
#else
	    RETVAL = -1 ;
#endif
	    for (i = items-1 ; i > 0 ; --i)
	    {
	        value.data = SvPV(ST(i), n_a) ;
	        value.size = n_a ;
	        One = 1 ;
	        key.data = &One ;
	        key.size = sizeof(int) ;
#ifdef DB_VERSION_MAJOR
           	RETVAL = (db->cursor->c_put)(db->cursor, &key, &value, DB_BEFORE) ;
#else
	        RETVAL = (Db->put)(Db, &key, &value, R_IBEFORE) ;
#endif
	        if (RETVAL != 0)
	            break;
	    }
	}
	OUTPUT:
	    RETVAL

I32
pop(db)
	DB_File		db
	ALIAS:		POP = 1
	CODE:
	{
	    DBTKEY	key ;
	    DBT		value ;

	    DBT_flags(key) ; 
	    DBT_flags(value) ; 
	    CurrentDB = db ;

	    /* First get the final value */
	    RETVAL = do_SEQ(db, key, value, R_LAST) ;	 
	    ST(0) = sv_newmortal();
	    /* Now delete it */
	    if (RETVAL == 0)
	    {
		/* the call to del will trash value, so take a copy now */
		OutputValue(ST(0), value) ;
	        RETVAL = db_del(db, key, R_CURSOR) ;
	        if (RETVAL != 0) 
	            sv_setsv(ST(0), &PL_sv_undef); 
	    }
	}

I32
shift(db)
	DB_File		db
	ALIAS:		SHIFT = 1
	CODE:
	{
	    DBT		value ;
	    DBTKEY	key ;

	    DBT_flags(key) ; 
	    DBT_flags(value) ; 
	    CurrentDB = db ;
	    /* get the first value */
	    RETVAL = do_SEQ(db, key, value, R_FIRST) ;	 
	    ST(0) = sv_newmortal();
	    /* Now delete it */
	    if (RETVAL == 0)
	    {
		/* the call to del will trash value, so take a copy now */
		OutputValue(ST(0), value) ;
	        RETVAL = db_del(db, key, R_CURSOR) ;
	        if (RETVAL != 0)
	            sv_setsv (ST(0), &PL_sv_undef) ;
	    }
	}


I32
push(db, ...)
	DB_File		db
	ALIAS:		PUSH = 1
	CODE:
	{
	    DBTKEY	key ;
	    DBT		value ;
	    DB *	Db = db->dbp ;
	    int		i ;
	    STRLEN	n_a;

	    DBT_flags(key) ; 
	    DBT_flags(value) ; 
	    CurrentDB = db ;
#ifdef DB_VERSION_MAJOR
	   	RETVAL = 0 ;
		key = empty ;
	        for (i = 1 ; i < items  ; ++i)
	        {
	            value.data = SvPV(ST(i), n_a) ;
	            value.size = n_a ;
	            RETVAL = (Db->put)(Db, NULL, &key, &value, DB_APPEND) ;
	            if (RETVAL != 0)
	                break;
		}
#else		
	    
	    /* Set the Cursor to the Last element */
	    RETVAL = do_SEQ(db, key, value, R_LAST) ;
	    if (RETVAL >= 0)
	    {
		if (RETVAL == 1)
		    key = empty ;
	        for (i = items - 1 ; i > 0 ; --i)
	        {
	            value.data = SvPV(ST(i), n_a) ;
	            value.size = n_a ;
	            RETVAL = (Db->put)(Db, &key, &value, R_IAFTER) ;
	            if (RETVAL != 0)
	                break;
	        }
	    }
#endif
	}
	OUTPUT:
	    RETVAL


I32
length(db)
	DB_File		db
	ALIAS:		FETCHSIZE = 1
	CODE:
	    CurrentDB = db ;
	    RETVAL = GetArrayLength(aTHX_ db) ;
	OUTPUT:
	    RETVAL


#
# Now provide an interface to the rest of the DB functionality
#

int
db_del(db, key, flags=0)
	DB_File		db
	DBTKEY		key
	u_int		flags
	CODE:
	  CurrentDB = db ;
	  RETVAL = db_del(db, key, flags) ;
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
	  else if (RETVAL == DB_NOTFOUND)
	    RETVAL = 1 ;
#endif
	OUTPUT:
	  RETVAL


int
db_get(db, key, value, flags=0)
	DB_File		db
	DBTKEY		key
	DBT		value = NO_INIT
	u_int		flags
	CODE:
	  CurrentDB = db ;
	  DBT_flags(value) ; 
	  RETVAL = db_get(db, key, value, flags) ;
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
	  else if (RETVAL == DB_NOTFOUND)
	    RETVAL = 1 ;
#endif
	OUTPUT:
	  RETVAL
	  value

int
db_put(db, key, value, flags=0)
	DB_File		db
	DBTKEY		key
	DBT		value
	u_int		flags
	CODE:
	  CurrentDB = db ;
	  RETVAL = db_put(db, key, value, flags) ;
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
	  else if (RETVAL == DB_KEYEXIST)
	    RETVAL = 1 ;
#endif
	OUTPUT:
	  RETVAL
	  key		if (flagSet(flags, R_IAFTER) || flagSet(flags, R_IBEFORE)) OutputKey(ST(1), key);

int
db_fd(db)
	DB_File		db
	int		status = 0 ;
	CODE:
	  CurrentDB = db ;
#ifdef DB_VERSION_MAJOR
	  RETVAL = -1 ;
	  status = (db->in_memory
		? -1 
		: ((db->dbp)->fd)(db->dbp, &RETVAL) ) ;
	  if (status != 0)
	    RETVAL = -1 ;
#else
	  RETVAL = (db->in_memory
		? -1 
		: ((db->dbp)->fd)(db->dbp) ) ;
#endif
	OUTPUT:
	  RETVAL

int
db_sync(db, flags=0)
	DB_File		db
	u_int		flags
	CODE:
	  CurrentDB = db ;
	  RETVAL = db_sync(db, flags) ;
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
#endif
	OUTPUT:
	  RETVAL


int
db_seq(db, key, value, flags)
	DB_File		db
	DBTKEY		key 
	DBT		value = NO_INIT
	u_int		flags
	CODE:
	  CurrentDB = db ;
	  DBT_flags(value) ; 
	  RETVAL = db_seq(db, key, value, flags);
#ifdef DB_VERSION_MAJOR
	  if (RETVAL > 0)
	    RETVAL = -1 ;
	  else if (RETVAL == DB_NOTFOUND)
	    RETVAL = 1 ;
#endif
	OUTPUT:
	  RETVAL
	  key
	  value

#ifdef DBM_FILTERING

#define setFilter(type)					\
	{						\
	    if (db->type)				\
	        RETVAL = newSVsv(db->type) ; 		\
	    if (db->type && (code == &PL_sv_undef)) {	\
                SvREFCNT_dec(db->type) ;		\
	        db->type = NULL ;			\
	    }						\
	    else if (code) {				\
	        if (db->type)				\
	            sv_setsv(db->type, code) ;		\
	        else					\
	            db->type = newSVsv(code) ;		\
	    }	    					\
	}


SV *
filter_fetch_key(db, code)
	DB_File		db
	SV *		code
	SV *		RETVAL = &PL_sv_undef ;
	CODE:
	    setFilter(filter_fetch_key) ;
	OUTPUT:
	    RETVAL

SV *
filter_store_key(db, code)
	DB_File		db
	SV *		code
	SV *		RETVAL = &PL_sv_undef ;
	CODE:
	    setFilter(filter_store_key) ;
	OUTPUT:
	    RETVAL

SV *
filter_fetch_value(db, code)
	DB_File		db
	SV *		code
	SV *		RETVAL = &PL_sv_undef ;
	CODE:
	    setFilter(filter_fetch_value) ;
	OUTPUT:
	    RETVAL

SV *
filter_store_value(db, code)
	DB_File		db
	SV *		code
	SV *		RETVAL = &PL_sv_undef ;
	CODE:
	    setFilter(filter_store_value) ;
	OUTPUT:
	    RETVAL

#endif /* DBM_FILTERING */
