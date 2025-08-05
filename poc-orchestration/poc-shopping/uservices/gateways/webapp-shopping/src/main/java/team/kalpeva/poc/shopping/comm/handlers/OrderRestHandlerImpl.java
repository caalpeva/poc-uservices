package team.kalpeva.poc.shopping.comm.handlers;

import io.vertx.core.Handler;
import io.vertx.ext.web.RoutingContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.kalpeva.poc.shopping.comm.requests.OrderRequest;
import team.kalpeva.poc.shopping.comm.deserializers.OrderRequestDeserializer;

import java.io.IOException;

public class OrderRestHandlerImpl implements OrderRestHandler, Handler<RoutingContext> {

    private static final Logger LOGGER = LoggerFactory.getLogger(OrderRestHandlerImpl.class.getName());

    public static final String URI_SERVICE = String.format("/%s", "orders");

    @Override
    public void createOrder(RoutingContext context) {
        String requestBody = extractRequestBodyAsTextPlain(context);
        LOGGER.info(String.format("Input order request: %s", requestBody));

            try {
            OrderRequest orderRequest = new OrderRequestDeserializer().from(requestBody);
            /*var mobileOrderTreatmentService = getMobileOrderTreatmentService(orderRequest.getOrderToTransform());
            if (mobileOrderTreatmentService != null) {
                processResponse(ctx, requestCorrelationId, orderRequest, mobileOrderTreatmentService);
            } else {
                processCrmIntegration(ctx, requestCorrelationId, ServiceFlow.CREATE);
            }*/

        } catch (IOException e) {
            LOGGER.error(String.format("Error in order request: %s", e.getMessage()));
            context.end("Failed");
        } finally {
            context.end("Success");
        }
    }

    @Override
    public void handle(RoutingContext context) {
        createOrder(context);
    }

    /*private MobileOrderTreatmentService getMobileOrderTreatmentService(TransformFlow transformFlow) {
        if (transformFlow != null && transformFlow.isActivated()) {
            switch (transformFlow) {
                case MOBILE_POSTPAID_NEW:
                    return mobilePostpaidNewService;
                case MOBILE_PREPAID_NEW:
                    return mobilePrepaidNewService;
            }
        }

        return null;
    }*/

    /*
    private void processResponse(RoutingContext ctx, String requestCorrelationId, OrderRequest orderRequest,
                                 MobileOrderTreatmentService mobilePostpaidService) throws Exception {
        mobilePostpaidService.processOrder(orderRequest).subscribe(
                result -> {
                    savePrometheusMetric(Constants.KEY_PROMETHEUS_POST_ORDERS_OK);
                    var jsonResult = Json.encodePrettily(result);
                    GenericLogger.info(LOGGER, String.format("Output orders request: %s", jsonResult), OperationType.RESPONSE,
                            null, requestCorrelationId);
                    ctx.response().putHeader(HeaderConstants.REQUEST_CORRELATION_ID, requestCorrelationId);

                    makeResponse(
                            ctx,
                            HttpResponseStatus.ACCEPTED.code(),
                            new Gson().toJson(new OrderResponse.Builder().addWorkflowResponse(result).build()),
                            Constants.HEADER_APPLICATION_JSON
                    );
                },
                throwable -> {
                    savePrometheusMetric(Constants.KEY_PROMETHEUS_POST_ORDERS_ERROR);
                    GenericLogger.error(LOGGER, String.format("Error in orders request: %s", throwable.getMessage()), throwable,
                            OperationType.INPUT,
                            null, requestCorrelationId);
                    generateErrorResponse(ctx, throwable);
                }
        );
    }
    */
}