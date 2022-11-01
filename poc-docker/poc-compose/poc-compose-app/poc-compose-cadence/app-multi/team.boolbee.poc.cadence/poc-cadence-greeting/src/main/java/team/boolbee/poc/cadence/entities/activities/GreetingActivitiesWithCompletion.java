package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.activity.Activity;
import com.uber.cadence.client.ActivityCompletionClient;

import java.util.concurrent.ForkJoinPool;

public class GreetingActivitiesWithCompletion implements IGreetingActivities {

    private final ActivityCompletionClient activityCompletionClient;

    public GreetingActivitiesWithCompletion(ActivityCompletionClient completionClient) {
        this.activityCompletionClient = completionClient;
    }

    /**
     * Demonstrates how to implement an activity asynchronously. When {@link
     * Activity#doNotCompleteOnReturn()} is called the activity implementation
     * function returning doesn't complete the activity.
     */
    @Override
    public String composeGreeting(String greeting, String name) {
        // TaskToken is a correlation token used to match an activity task with its completion
        byte[] taskToken = Activity.getTaskToken();

        // In real life this request can be executed anywhere. By a separate service for example.
        ForkJoinPool.commonPool().execute(() -> composeGreetingAsync(taskToken, greeting, name));

        // When doNotCompleteOnReturn() is invoked the return value is ignored.
        Activity.doNotCompleteOnReturn();
        return "ignored";
    }

    private void composeGreetingAsync(byte[] taskToken, String greeting, String name) {
        String result = greeting + " " + name + "!";
        // To complete an activity from a different thread or process use ActivityCompletionClient.
        // In real applications the client is initialized by a process that performs the completion.
        activityCompletionClient.complete(taskToken, result);
    }
}