package team.kalpeva.poc.payment.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import team.kalpeva.poc.payment.model.PaymentRequest;
import team.kalpeva.poc.payment.model.PaymentResponse;
import team.kalpeva.poc.payment.model.PaymentStatus;

import javax.annotation.PostConstruct;

@Service
public class PaymentServiceImpl implements PaymentService {

	private Map<Integer, Double> userBalanceMap;

	@PostConstruct
	private void init(){
		this.userBalanceMap = new HashMap<>();
		this.userBalanceMap.put(1, 1000d);
		this.userBalanceMap.put(2, 1000d);
		this.userBalanceMap.put(3, 1000d);
	}

	public PaymentResponse debit(final PaymentRequest request) {
		double balance = userBalanceMap.getOrDefault(request.getUserId(), 0d);
		PaymentResponse response = new PaymentResponse();
		response.setUserId(request.getUserId());
		response.setOrderId(request.getOrderId());
		response.setStatus(PaymentStatus.PAYMENT_REJECTED);
		if (balance >= request.getAmount()){
			balance -= request.getAmount();
			userBalanceMap.put(request.getUserId(), balance);
			response.setStatus(PaymentStatus.PAYMENT_APPROVED);
		}
		response.setAmount(balance);
		return response;
	}

	public void credit(final PaymentRequest request) {
		userBalanceMap.computeIfPresent(request.getUserId(), (k, v) -> v + request.getAmount());
	}
}