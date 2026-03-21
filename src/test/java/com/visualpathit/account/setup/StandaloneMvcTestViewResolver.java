package com.visualpathit.account.setup;

import org.springframework.web.servlet.view.AbstractUrlBasedView;
import org.springframework.web.servlet.view.InternalResourceView;
import org.springframework.web.servlet.view.InternalResourceViewResolver;

public class StandaloneMvcTestViewResolver extends InternalResourceViewResolver {

	public StandaloneMvcTestViewResolver() {
		super();
	}

	@Override
	@org.springframework.lang.NonNull
	protected AbstractUrlBasedView buildView(@org.springframework.lang.NonNull final String viewName) throws Exception {
		final AbstractUrlBasedView view = super.buildView(viewName);
		// prevent checking for circular view paths
		if (view instanceof InternalResourceView) {
			((InternalResourceView) view).setPreventDispatchLoop(false);
		}
		return view;
	}
}
