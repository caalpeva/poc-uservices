package team.kalpeva.workflow.purchase;

import team.kalpeva.activity.inventory.InventoryActivity;
import com.uber.cadence.workflow.Workflow;

public class PurchaseWorkflowImpl implements PurchaseWorkflow {

    private final InventoryActivity activities =
            Workflow.newActivityStub(InventoryActivity.class);

    @Override
    public String execute(String name) {
        //return "Hello " + name + "!";
        // This is a blocking call that returns only after the activity has completed.
        return activities.composeGreeting("Hello", name);
    }
}
