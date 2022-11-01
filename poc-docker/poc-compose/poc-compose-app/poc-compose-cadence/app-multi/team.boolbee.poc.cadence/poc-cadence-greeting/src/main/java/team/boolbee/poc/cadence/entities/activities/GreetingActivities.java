package team.boolbee.poc.cadence.entities.activities;

import java.util.ArrayList;
import java.util.List;

public class GreetingActivities implements IGreetingActivities {

    private final List<String> invocations = new ArrayList<>();

    @Override
    public String composeGreeting(String greeting, String name) {
        invocations.add("composeGreeting");
        return greeting + " " + name + "!";
    }

    public List<String> getInvocations() {
        return invocations;
    }
}