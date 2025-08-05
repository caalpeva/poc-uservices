package team.kalpeva.poc.shopping.handlers;

import io.netty.handler.codec.http.HttpResponseStatus;
import io.reactivex.rxjava3.core.Single;
import io.reactivex.rxjava3.functions.Consumer;
import io.vertx.core.Handler;
import io.vertx.core.json.Json;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.RequestBody;
import io.vertx.ext.web.RoutingContext;
import lombok.extern.slf4j.Slf4j;
import team.kalpeva.poc.shopping.manager.ShoppingManager;
import team.kalpeva.poc.shopping.model.ShoppingRequest;
import team.kalpeva.poc.shopping.model.ShoppingResponse;
import team.kalpeva.poc.shopping.model.WorkflowResponse;

import javax.inject.Inject;
import java.util.Optional;
import java.util.function.Supplier;

@Slf4j
public class ShoppingRestHandlerImpl implements Handler<RoutingContext> {

    private final ShoppingManager shoppingManager;

    @Inject
    public ShoppingRestHandlerImpl(ShoppingManager shoppingManager) {
        this.shoppingManager = shoppingManager;
    }

    @Override
    public void handle(RoutingContext context) {
        log.info("Request received: {}", extractBodyFrom(context.body()));
        executeSafely(() -> context.getBodyAsJson().mapTo(ShoppingRequest.class))
                .flatMap(shoppingManager::manage)
                .subscribe(complete(context), fail(context));
    }

    private <S> Single<S> executeSafely(Supplier<S> operation) {
        return Single.create(emitter -> {
            try {
                S result = operation.get();
                emitter.onSuccess(result);
            } catch(Exception e) {
                emitter.onError(e);

            }
        });
    }

    private Consumer<WorkflowResponse> complete(RoutingContext context) {
        return response -> createResponse(context, JsonObject.mapFrom(
                ShoppingResponse.builder()
                        .message(response.getMessage())
                        .build()));
    }

    private Consumer<Throwable> fail(RoutingContext context) {
        return throwable -> createErrorResponse(context, throwable);
    }

    private String extractBodyFrom(RequestBody requestBody) {
        return Optional.ofNullable(requestBody)
                .map(RequestBody::asJsonObject)
                .map(Object::toString)
                .orElse("");
    }

    private void createResponse(RoutingContext context, JsonObject response) {
        String jsonResult = Json.encodePrettily(response);
        log.info("Response sent: {}", jsonResult);
        context.response()
                .putHeader("Content-Type", "application/json")
                .setStatusCode(HttpResponseStatus.OK.code())
                .end(jsonResult);
    }

    private void createErrorResponse(RoutingContext context, Throwable throwable) {
        log.error("Fallo: ", throwable);
        context.response()
                .putHeader("Content-Type", "application/json")
                .setStatusCode(HttpResponseStatus.INTERNAL_SERVER_ERROR.code())
                .end("");
    }
}