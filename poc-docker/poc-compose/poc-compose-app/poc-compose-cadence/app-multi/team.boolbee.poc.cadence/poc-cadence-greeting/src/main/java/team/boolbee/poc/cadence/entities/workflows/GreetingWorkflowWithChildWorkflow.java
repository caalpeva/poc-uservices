package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.workflow.Async;
import com.uber.cadence.workflow.Promise;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingWorkflowWithChildWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        // Workflows are stateful. So a new stub must be created for each new child.
        IGreetingChildWorkflow childWorkflow = Workflow.newChildWorkflowStub(IGreetingChildWorkflow.class);

        //return waitForChildWorkflowExecution(childWorkflow, name);
        return executeChildWorkflowParallel(childWorkflow, name);
    }

    private String waitForChildWorkflowExecution(IGreetingChildWorkflow childWorkflow, String name) {
        // Use child.composeGreeting("Hello", name) to call synchronously.
        // This is a non blocking call that returns immediately.
        Promise<String> greeting = Async.function(childWorkflow::composeGreeting, "Hello", name);
        // Do something else here.
        return greeting.get(); // blocks waiting for the child to complete.
    }

    private String executeChildWorkflowParallel(IGreetingChildWorkflow childWorkflow, String name) {
        IGreetingChildWorkflow child = Workflow.newChildWorkflowStub(IGreetingChildWorkflow.class);
        Promise<String> greeting = Async.function(childWorkflow::composeGreeting, "Hello", name);
        // Instead of using greeting.get() to block till child complete,
        // sometimes we just want to return parent immediately and keep child running
        Promise<WorkflowExecution> childPromise = Workflow.getWorkflowExecution(childWorkflow);
        childPromise.get(); // block until child started,
        // otherwise child may not start because parent complete first.
        return "let child run, parent just return";
    }
}