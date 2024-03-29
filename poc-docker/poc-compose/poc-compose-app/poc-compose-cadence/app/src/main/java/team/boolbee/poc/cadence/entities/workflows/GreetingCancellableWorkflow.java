package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.CancellationScope;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;
import java.util.concurrent.CancellationException;

public class GreetingCancellableWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        try {
            final String result = activities.composeGreeting("Hello", name);
            Workflow.sleep(Duration.ofDays(10));
            return result;
        } catch (CancellationException e) {
            /**
             * This exception is thrown when a cancellation is requested on the current workflow.
             * Any call to an activity or a child workflow after the workflow is cancelled is going to
             * fail immediately with the CancellationException. the DetachedCancellationScope doesn't
             * inherit its cancellation status from the enclosing scope. Thus it allows running a
             * cleanup activity even if the workflow cancellation was requested.
             */
            CancellationScope scope = Workflow.newDetachedCancellationScope(
                    () -> activities.composeGreeting("Bye", name));
            scope.run();
            logger.warn("Cancellation exception caught and thrown again");
            throw e;
        }
    }
}