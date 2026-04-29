package ignite

import std.collection.ArrayList

@Test
public class AppDispatchPlanInternalTestSuite {
    @TestCase
    public func testResolveAppDispatchPlanBuildsMatchedRoutePlan(): Unit {
        let app = App()
        app.use({ ctx =>
            ctx.next()
        })
        app.get("/users/:id", { ctx =>
            let _ = ctx.sendString(ctx.params("id"))
        })

        let plan = resolveAppDispatchPlan(app, "GET", "/users/42")

        @Assert(plan.matched(), true)
        @Assert(plan.kindName(), "matched")
        @Assert(plan.requestMethod, "GET")
        @Assert(plan.requestPath, "/users/42")
        @Assert(plan.params.get("id") ?? "", "42")
        @Assert(plan.handlers.size, Int64(2))
        @Assert(plan.allowedMethods.size, Int64(0))
        match (plan.route) {
            case Some(route) =>
                @Assert(route.method, "GET")
                @Assert(route.path, "/users/:id")
            case None => @Fail("matched dispatch plan should keep selected route")
        }
    }

    @TestCase
    public func testResolveAppDispatchPlanBuildsMethodNotAllowedFallbackPlan(): Unit {
        let app = App()
        app.use({ ctx =>
            ctx.next()
        })
        app.get("/users", { ctx =>
            let _ = ctx.sendString("users")
        })

        let plan = resolveAppDispatchPlan(app, "POST", "/users")

        @Assert(plan.matched(), false)
        @Assert(plan.kindName(), "method-not-allowed")
        @Assert(plan.requestMethod, "POST")
        @Assert(plan.requestPath, "/users")
        @Assert(plan.params.size, Int64(0))
        @Assert(plan.handlers.size, Int64(2))
        @Assert(containsDispatchPlanMethod(plan.allowedMethods, "GET"), true)
        match (plan.route) {
            case Some(_) => @Fail("method-not-allowed fallback should not keep a matched route")
            case None => ()
        }
    }

    @TestCase
    public func testResolveAppDispatchPlanDoesNotNeedHttpContextForNotFoundPlanning(): Unit {
        let app = App()
        app.use({ ctx =>
            ctx.next()
        })
        app.get("/health", { ctx =>
            let _ = ctx.sendString("ok")
        })

        let plan = resolveAppDispatchPlan(app, "DELETE", "/missing")

        @Assert(plan.matched(), false)
        @Assert(plan.kindName(), "not-found")
        @Assert(plan.requestMethod, "DELETE")
        @Assert(plan.requestPath, "/missing")
        @Assert(plan.params.size, Int64(0))
        @Assert(plan.handlers.size, Int64(2))
        @Assert(plan.allowedMethods.size, Int64(0))
        match (plan.route) {
            case Some(_) => @Fail("not-found planning should not require a selected route")
            case None => ()
        }
    }
}

func containsDispatchPlanMethod(methods: ArrayList<String>, target: String): Bool {
    for (method in methods) {
        if (method == target) {
            return true
        }
    }
    false
}
