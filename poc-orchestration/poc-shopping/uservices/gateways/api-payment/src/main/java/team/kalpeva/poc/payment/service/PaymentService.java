package team.kalpeva.poc.payment.service;

import java.util.List;

import team.kalpeva.poc.payment.model.PaymentRequest;
import team.kalpeva.poc.payment.model.PaymentResponse;

public interface PaymentService {
	public PaymentResponse debit(final PaymentRequest request);
	public void credit(final PaymentRequest request);
}