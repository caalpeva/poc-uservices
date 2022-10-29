package team.boolbee.poc.cadence.activities;

public class GreetingActivities implements IGreetingActivities {

    @Override
    public String composeGreeting(String greeting, String name) {
        return greeting + " " + name + "!";
    }
  }