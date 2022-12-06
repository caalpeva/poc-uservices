package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.WorkflowIdReusePolicy;
import com.uber.cadence.common.CronSchedule;
import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingCronWorkflow {
    @WorkflowMethod(
            executionStartToCloseTimeoutSeconds = 30,
            // To allow starting workflow with the same ID after the previous one has terminated.
            workflowIdReusePolicy = WorkflowIdReusePolicy.AllowDuplicate
    )
    @CronSchedule("*/1 * * * *") // new workflow run every minute
    void greetPeriodically(String name);
}