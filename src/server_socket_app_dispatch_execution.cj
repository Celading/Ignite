package ignite

import stdx.net.http.HttpContext

func prepareCurrentCarrierDispatchContext(
    app: App,
    httpCtx: HttpContext,
    plan: AppDispatchPlan
): ?Ctx {
    let ctx = Ctx(httpCtx, app)
    ctx.setParams(plan.params)
    ctx.setHandlers(plan.handlers)

    if (plan.matched()) {
        if (let Some(route) <- plan.route) {
            ctx.setRoute(route)
        }
        if (app.maybeHandleTestOption(ctx)) {
            return None
        }
    }

    Some(ctx)
}

func executePreparedCurrentCarrierDispatch(app: App, httpCtx: HttpContext, ctx: Ctx): Unit {
    try {
        ctx.next()
    } catch (e: Exception) {
        if (app.config.kmode) {
            if (let Some(kmodePanicHandler) <- app.config.kmodePanicHandler) {
                if (kmodePanicHandler(ctx, e)) {
                    return
                }
            }
        }
        if (let Some(errorHandler) <- app._errorHandler) {
            errorHandler(ctx, e)
        } else {
            httpCtx.responseBuilder
                .status(500)
                .header("content-type", "text/plain; charset=utf-8")
                .body("Internal Server Error")
        }
    }
}
