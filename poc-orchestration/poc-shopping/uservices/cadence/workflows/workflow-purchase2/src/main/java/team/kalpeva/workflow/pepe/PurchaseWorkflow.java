package team.kalpeva.workflow.pepe;

import com.uber.cadence.workflow.WorkflowMethod;

public interface PurchaseWorkflow {

    @WorkflowMethod()
    String execute(String name);
}
