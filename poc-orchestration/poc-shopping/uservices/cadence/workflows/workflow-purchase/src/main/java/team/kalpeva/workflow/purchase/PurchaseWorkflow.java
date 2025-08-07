package team.kalpeva.workflow.purchase;

import com.uber.cadence.workflow.WorkflowMethod;

public interface PurchaseWorkflow {

    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 20)
    String execute(String name);
}
