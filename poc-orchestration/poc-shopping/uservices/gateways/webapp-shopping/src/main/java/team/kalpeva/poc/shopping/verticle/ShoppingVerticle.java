package team.kalpeva.poc.shopping.verticle;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.core.http.HttpMethod;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.RoutingContext;
import io.vertx.ext.web.handler.StaticHandler;
import io.vertx.ext.web.openapi.router.RouterBuilder;
import io.vertx.openapi.contract.OpenAPIContract;
import lombok.extern.slf4j.Slf4j;

import javax.inject.Inject;
import javax.inject.Named;

@Slf4j
public class ShoppingVerticle extends AbstractVerticle {

    public static final int PORT = 9090;
    public static final String OPENAPI_PATH = "openapi.yaml";

    private final Handler<RoutingContext> handler;
    private final Handler<RoutingContext> failureHandler;

    @Inject
    public ShoppingVerticle(@Named("shoppingRestHandler") Handler<RoutingContext> handler,
                            @Named("genericFailureHandler") Handler<RoutingContext> failureHandler) {
        this.handler = handler;
        this.failureHandler = failureHandler;
    }

    @Override
    public void start(Promise<Void> startPromise) throws Exception {
        OpenAPIContract.from(vertx, OPENAPI_PATH)
                .compose(contract -> {
                    RouterBuilder builderRouter = RouterBuilder.create(vertx, contract);
                    Router opeanApiRouter = builderRouter.createRouter();
                    opeanApiRouter.route(HttpMethod.POST, "/order")
                            .handler(handler)
                            .failureHandler(failureHandler);

                    Router mainRouter = Router.router(vertx);
                    mainRouter.route("/v1/*").subRouter(opeanApiRouter);
                    mainRouter.route("/*").handler(StaticHandler.create("swagger-ui"));
                    mainRouter.get("/openapi.yaml").handler(ctx ->
                            ctx.response()
                                    .putHeader("Content-Type", "application/yaml")
                                    .sendFile(OPENAPI_PATH)
                    );

                    return vertx.createHttpServer()
                            .requestHandler(mainRouter)
                            .listen(PORT);
                }).onSuccess(server -> {
                    startPromise.complete();
                    log.info("Server started on port: {}", server.actualPort());
                }).onFailure(t -> {
                    log.error("HTTP server failed to start: {}", t.getMessage());
                    startPromise.fail(t);
                });
    }
}
