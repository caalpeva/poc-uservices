package team.kalpeva.workflow.purchase;

import com.uber.cadence.workflow.WorkflowMethod;

public interface PurchaseWorkflow {

    @WorkflowMethod()
    String execute(String name);
}
