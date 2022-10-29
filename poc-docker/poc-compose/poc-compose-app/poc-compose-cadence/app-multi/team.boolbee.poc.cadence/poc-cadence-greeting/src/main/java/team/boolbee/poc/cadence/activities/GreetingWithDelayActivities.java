package team.boolbee.poc.cadence.activities;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GreetingWithDelayActivities implements IGreetingActivities {

    private static Logger logger = LoggerFactory.getLogger(GreetingWithDelayActivities.class);
    private int callCount;
    private long lastInvocationTime;

    @Override
    public synchronized String composeGreeting(String greeting, String name) {
        if (lastInvocationTime != 0) {
            long timeSinceLastInvocation = System.currentTimeMillis() - lastInvocationTime;
            logger.info(timeSinceLastInvocation + " milliseconds since last invocation. ");
        }

        lastInvocationTime = System.currentTimeMillis();
        if (++callCount < 4) {
            logger.info("composeGreeting activity is going to fail");
            throw new IllegalStateException("not yet");
        }

        logger.info("composeGreeting activity is going to complete");
        return greeting + " " + name + "!";
    }
  }