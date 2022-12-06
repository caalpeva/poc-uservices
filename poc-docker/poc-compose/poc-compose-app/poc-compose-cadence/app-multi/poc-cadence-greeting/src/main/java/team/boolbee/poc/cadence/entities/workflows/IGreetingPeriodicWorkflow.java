package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.WorkflowIdReusePolicy;
import com.uber.cadence.common.CronSchedule;
import com.uber.cadence.workflow.WorkflowMethod;

import java.time.Duration;

public interface IGreetingPeriodicWorkflow {
    /**
     * Use single fixed ID to ensure that there is at most one instance running. To run multiple
     * instances set different IDs through WorkflowOptions passed to the WorkflowClient.newWorkflowStub call.
     */
    @WorkflowMethod(
            // At most one instance.
            //workflowId = PERIODIC_WORKFLOW_ID,
            //taskList = TASK_LIST,
            // To allow starting workflow with the same ID after the previous one has terminated.
            workflowIdReusePolicy = WorkflowIdReusePolicy.AllowDuplicate,
            // Adjust this value to the maximum time workflow is expected to run.
            // It usually depends on the number of repetitions and interval between them.
            executionStartToCloseTimeoutSeconds = 300
    )
    void greetPeriodically(String name, Duration delay);
}