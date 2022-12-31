package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.workflow.Async;
import com.uber.cadence.workflow.Promise;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingParentWorkflow implements IGreetingParentWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    @Override
    public String getGreeting(String name, boolean parallel) {
        // Workflows are stateful. So a new stub must be created for each new child.
        IGreetingChildWorkflow childWorkflow = Workflow.newChildWorkflowStub(IGreetingChildWorkflow.class);

        if (parallel) {
            return executeChildWorkflowParallel(childWorkflow, name);
        } else {
            return waitForChildWorkflowExecution(childWorkflow, name);
        }
    }

    private String waitForChildWorkflowExecution(IGreetingChildWorkflow childWorkflow, String name) {
        // Use childWorkflow.composeGreeting("Hello", name) to call synchronously.
        // This is a non blocking call that returns immediately.
        Promise<String> greeting = Async.function(childWorkflow::composeGreeting, "Hello", name);
        // Do something else here.
        return greeting.get(); // blocks waiting for the child to complete.
    }

    private String executeChildWorkflowParallel(IGreetingChildWorkflow childWorkflow, String name) {
        // non blocking call that initiated child workflow
        Promise<String> greeting = Async.function(childWorkflow::composeGreeting, "Hello", name);
        // Instead of using greeting.get() to block till child complete,
        // sometimes we just want to return parent immediately and keep child running
        Promise<WorkflowExecution> childPromise = Workflow.getWorkflowExecution(childWorkflow);
        childPromise.get(); // block until child started,
        // otherwise child may not start because parent complete first.
        return "let child run, parent just return";
    }
}