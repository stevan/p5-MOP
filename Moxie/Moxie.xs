#include "EXTERN.h"
#include "perl.h"
#include "callparser1.h"
#include "XSUB.h"

/* ======================================================= */
// BEGIN: Shameless Steal from Parse::Keyword
/* ======================================================= */

#ifndef cv_clone
#define cv_clone(a) Perl_cv_clone(aTHX_ a)
#endif

static SV *parser_fn(OP *(fn)(pTHX_ U32), bool named) {
    I32 floor;
    CV *code;
    U8 errors;

    ENTER;

    PL_curcop = &PL_compiling;
    SAVEVPTR(PL_op);
    SAVEI8(PL_parser->error_count);
    PL_parser->error_count = 0;

    floor = start_subparse(0, named ? 0 : CVf_ANON);
    code = newATTRSUB(floor, NULL, NULL, NULL, fn(aTHX_ 0));

    errors = PL_parser->error_count;

    LEAVE;

    if (errors) {
        ++PL_parser->error_count;
        return newSV(0);
    }
    else {
        if (CvCLONE(code)) {
            code = cv_clone(code);
        }

        return newRV_inc((SV*)code);
    }
}

static OP *parser_callback(pTHX_ GV *namegv, SV *psobj, U32 *flagsp) {
    dSP;
    SV *args_generator;
    SV *statement = NULL;
    I32 count;

    /* call the parser callback
     * it should take no arguments and return a coderef which, when called,
     * produces the arguments to the keyword function
     * the optree we want to generate is for something like
     *   mykeyword($code->())
     * where $code is the thing returned by the parser function
     */

    PUSHMARK(SP);
    mXPUSHp(GvNAME(namegv), GvNAMELEN(namegv));
    PUTBACK;
    count = call_sv(psobj, G_ARRAY);
    SPAGAIN;
    if (count > 1) {
        statement = POPs;
    }
    args_generator = SvREFCNT_inc(POPs);
    PUTBACK;

    if (!SvROK(args_generator) || SvTYPE(SvRV(args_generator)) != SVt_PVCV) {
        croak("The parser function for %s must return a coderef, not %"SVf,
              GvNAME(namegv), args_generator);
    }

    if (SvTRUE(statement)) {
        *flagsp |= CALLPARSER_STATEMENT;
    }

    return newUNOP(OP_ENTERSUB, OPf_STACKED,
                   newCVREF(0, newSVOP(OP_CONST, 0, args_generator)));
}

/* ======================================================= */
// END: Shameless Steal from Parse::Keyword
/* ======================================================= */

MODULE = Moxie  PACKAGE = Moxie::Util::Syntax

# NOTE:
# Everything in this package has been stolen from
# Parse::Keyword, it could almost certainly use some
# improvement, but is good for now.
# - SL

PROTOTYPES: DISABLE

void
install_keyword_handler(keyword, handler)
        SV *keyword
        SV *handler
    CODE:
        if (SvTYPE(keyword) != SVt_RV && SvTYPE(SvRV(keyword)) != SVt_PVCV) {
            croak("'keyword' argument is not a CODE reference");
        }
        if (SvTYPE(handler) != SVt_RV && SvTYPE(SvRV(handler)) != SVt_PVCV) {
            croak("'handler' argument is not a CODE reference");
        }
        cv_set_call_parser( (CV*) SvRV( keyword ), parser_callback, handler );

SV*
parse_full_statement(named = FALSE)
        bool named
    CODE:
        RETVAL = parser_fn( Perl_parse_fullstmt, named );
    OUTPUT:
        RETVAL






