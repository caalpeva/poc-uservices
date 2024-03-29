package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Async;
import com.uber.cadence.workflow.Promise;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingWorkflowWithAsyncActivity implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        // Async.invoke takes method reference and activity parameters and returns Promise.
        Promise<String> hello = Async.function(activities::composeGreeting, "Hello", name);
        /*Promise<String> hello = Async.function(() -> {
            return activities.composeGreeting("Hello", name);
        });*/
        // Async.invoke accepts not only activity or child workflow method references
        // but lambda functions as well. Behind the scene it allocates a thread
        // to execute it asynchronously.
        //Promise<String> bye = Async.function(activities::composeGreeting, "Bye", name);
        Promise<String> bye = Async.function(() -> {
            return activities.composeGreeting("Bye", name);
        });

        // Promise is similar to the Java Future. Promise#get blocks until result is ready.
        return hello.get() + "\n" + bye.get();
    }
}