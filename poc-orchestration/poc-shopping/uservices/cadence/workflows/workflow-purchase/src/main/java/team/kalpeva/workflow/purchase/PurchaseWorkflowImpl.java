package team.kalpeva.workflow.purchase;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.workflow.Workflow;
import team.kalpeva.activity.inventory.InventoryActivity;

import java.time.Duration;

public class PurchaseWorkflowImpl implements PurchaseWorkflow {

    private final static String ACTIVITY_TASKLIST = "tl-activities-inventory-v1";

    private final ActivityOptions options = new ActivityOptions.Builder()
            .setTaskList(ACTIVITY_TASKLIST)
            .setScheduleToCloseTimeout(Duration.ofMinutes(5))
            .build();

    private final InventoryActivity activities =
            Workflow.newActivityStub(InventoryActivity.class, options);

    @Override
    public String execute(String name) {
        //return "Hello " + name + "!";
        // This is a blocking call that returns only after the activity has completed.
        return activities.calculate("Hello", name);
    }
}
