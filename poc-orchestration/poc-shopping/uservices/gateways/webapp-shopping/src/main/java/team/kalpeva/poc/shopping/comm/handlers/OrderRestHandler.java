package team.kalpeva.poc.shopping.comm.handlers;

import io.vertx.ext.web.RequestBody;
import io.vertx.ext.web.RoutingContext;

public interface OrderRestHandler {

    default String extractRequestBodyAsTextPlain(RoutingContext context) {
        if (context != null) {
            RequestBody requestBody = context.body();
            if (requestBody != null && requestBody.asJsonObject() != null) {
                return requestBody.asJsonObject().toString();
            } else {
                return "";
            }
        }

        return null;
    }

    void createOrder(RoutingContext ctx);
}
