package team.kalpeva.poc.shopping.di;

import dagger.Module;
import dagger.Provides;
import io.vertx.core.cli.annotations.Name;
import team.kalpeva.poc.shopping.handlers.GenericFailureHandler;
import team.kalpeva.poc.shopping.handlers.ShoppingRestHandlerImpl;
import team.kalpeva.poc.shopping.manager.ShoppingManager;

import javax.inject.Named;
import javax.inject.Singleton;

@Module
public class HandlerModule {

    @Singleton
    @Provides
    @Named("shoppingRestHandler")
    public io.vertx.core.Handler<io.vertx.ext.web.RoutingContext> provideRestHandler(ShoppingManager shoppingManager) {
        return new ShoppingRestHandlerImpl(shoppingManager);
    }

    @Singleton
    @Provides
    @Named("genericFailureHandler")
    public io.vertx.core.Handler<io.vertx.ext.web.RoutingContext> provideGenericFailureHandler() {
        return new GenericFailureHandler();
    }
}
