
#ifndef PERL_REGINLINE_H

/*
 - regnext - dig the "next" pointer out of a node
 */
PERL_STATIC_INLINE
regnode *
Perl_regnext(pTHX_ const regnode *p)
{
    I32 offset;

    if (!p)
        return(NULL);

    if (OP(p) > REGNODE_MAX) {                /* regnode.type is unsigned */
        Perl_croak(aTHX_ "Corrupted regexp opcode %d > %d",
                                                (int)OP(p), (int)REGNODE_MAX);
    }

    offset = (REGNODE_OFF_BY_ARG(OP(p)) ? ARG(p) : NEXT_OFF(p));
    if (offset == 0)
        return(NULL);

    return(regnode *)(p+offset);
}

/*
 - regnode_after - find the node physically following p in memory,
   taking into account the size of p as determined by OP(p), our
   sizing data, and possibly the STR_SZ() macro.
 */
PERL_STATIC_INLINE
regnode *
Perl_regnode_after(pTHX_ const regnode *p, const bool varies)
{
    assert(p);
    const U8 op = OP(p);
    assert(op < REGNODE_MAX);
    const regnode *ret = p + NODE_STEP_REGNODE + REGNODE_ARG_LEN(op);
    if (varies || PL_regnode_arg_len_varies[op])
        ret += STR_SZ(STR_LEN(p));
    return (regnode *)ret;
}

/* validate that the passed in node and extra length would match that
 * returned by regnode_after() */
PERL_STATIC_INLINE
bool
Perl_check_regnode_after(pTHX_ const regnode *p, const STRLEN extra)
{
    const regnode *nextoper = regnode_after((regnode *)p,FALSE);
    const regnode *other = REGNODE_AFTER_PLUS(p, extra);
    if (nextoper != other) {
        return FALSE;
    }
    return TRUE;
}

#define PERL_REGINLINE_H
#endif
/*
 * ex: set ts=8 sts=4 sw=4 et:
 */
