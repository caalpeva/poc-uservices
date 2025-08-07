package team.kalpeva.poc.shopping.manager;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import io.reactivex.rxjava3.core.Single;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.kalpeva.poc.shopping.model.ShoppingRequest;
import team.kalpeva.poc.shopping.model.WorkflowResponse;
import team.kalpeva.workflow.purchase.PurchaseWorkflow;

import javax.inject.Inject;

public class ShoppingManagerImpl implements ShoppingManager {

    private final static String CADENCE_DOMAIN = "poc-shopping";
    private final static String TASKLIST = "tl-workflow-purchase-v1";

    private CadenceManager cadenceManager;

    @Inject
    public ShoppingManagerImpl(CadenceManager cadenceManager) {
        this.cadenceManager = cadenceManager;
    }

    @Override
    public Single<WorkflowResponse> manage(ShoppingRequest request) {
        return Single.fromCallable(() -> {
            WorkflowClient workflowClient = cadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
            PurchaseWorkflow workflow = workflowClient.newWorkflowStub(
                    PurchaseWorkflow.class,
                    new WorkflowOptions.Builder()
                            .setTaskList(TASKLIST)
                            .build());
            return workflow.execute("PERICO");
        }).map(message -> WorkflowResponse.builder()
                .message("HOLA PERICOOOOOOOO")
                .build());
/*        return Single.just(WorkflowResponse.builder()
                .message("HOLA PERICOOOOOOOO")
                .build());*/
    }
}
