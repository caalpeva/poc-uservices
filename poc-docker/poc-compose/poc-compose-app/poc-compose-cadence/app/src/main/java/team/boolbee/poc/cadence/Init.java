package team.boolbee.poc.cadence;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class Init {
    private static Logger logger = LoggerFactory.getLogger(Init.class);

    public static void main(String[] args) {
        CadenceManager.registerDomain(CADENCE_DOMAIN);
        System.exit(0);
    }
}