package team.kalpeva.poc.shopping.di;

import dagger.Module;
import dagger.Provides;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.kalpeva.poc.shopping.handlers.ShoppingRestHandlerImpl;
import team.kalpeva.poc.shopping.manager.ShoppingManager;
import team.kalpeva.poc.shopping.manager.ShoppingManagerImpl;

import javax.inject.Named;
import javax.inject.Singleton;

@Module
public class ManagerModule {

    @Singleton
    @Provides
    public ShoppingManager provideRestHandler(CadenceManager cadenceManager) {
        return new ShoppingManagerImpl(cadenceManager);
    }

    @Provides
    public CadenceManager provideCadenceManager() {
        return new CadenceManager();
    }
}
