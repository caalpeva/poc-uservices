package team.kalpeva.poc.payment.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import team.kalpeva.poc.payment.model.PaymentRequest;
import team.kalpeva.poc.payment.model.PaymentResponse;
import team.kalpeva.poc.payment.service.PaymentService;

@RestController
@RequestMapping("/api")
public class PaymentController {
	
	@Autowired
	private PaymentService paymentService;

	@PostMapping("/debit")
	public PaymentResponse debit(@RequestBody PaymentRequest request){
		return paymentService.debit(request);
	}

	@PostMapping("/credit")
	public void credit(@RequestBody PaymentRequest request){
		paymentService.credit(request);
	}
}