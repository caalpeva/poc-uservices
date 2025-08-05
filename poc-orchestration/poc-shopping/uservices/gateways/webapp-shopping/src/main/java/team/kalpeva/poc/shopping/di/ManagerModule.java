package team.kalpeva.poc.shopping.di;

import dagger.Module;
import dagger.Provides;
import team.kalpeva.poc.shopping.handlers.ShoppingRestHandlerImpl;
import team.kalpeva.poc.shopping.manager.ShoppingManager;
import team.kalpeva.poc.shopping.manager.ShoppingManagerImpl;

import javax.inject.Named;
import javax.inject.Singleton;

@Module
public class ManagerModule {

    @Singleton
    @Provides
    public ShoppingManager provideRestHandler() {
        return new ShoppingManagerImpl();
    }
}
