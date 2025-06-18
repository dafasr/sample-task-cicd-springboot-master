package TestAssessment.dafa.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String sayHello() {
        return "Aplikasi Spring Boot Anda berjalan!";
    }

    @GetMapping("/greet")
    public String greetWithName(@RequestParam(name = "name", defaultValue = "Guest") String name) {
        return "Halo, " + name + "!";
    }
}