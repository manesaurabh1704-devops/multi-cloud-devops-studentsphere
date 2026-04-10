package com.student.registration.student_registration_backend.controller;

import com.student.registration.student_registration_backend.model.User;
import com.student.registration.student_registration_backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // CREATE - Register new student
    @PostMapping("/register")
    public ResponseEntity<User> registerUser(@RequestBody User user) {
        User saved = userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // READ ALL - Get all students
    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }

    // READ ONE - Get student by ID
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    // UPDATE - Update student by ID
    @PutMapping("/users/{id}")
    public ResponseEntity<User> updateUser(
            @PathVariable Long id,
            @RequestBody User updatedUser) {
        return userRepository.findById(id)
            .map(user -> {
                user.setName(updatedUser.getName());
                user.setEmail(updatedUser.getEmail());
                user.setCourse(updatedUser.getCourse());
                user.setStudentClass(updatedUser.getStudentClass());
                user.setPercentage(updatedUser.getPercentage());
                user.setBranch(updatedUser.getBranch());
                user.setMobileNumber(updatedUser.getMobileNumber());
                return ResponseEntity.ok(userRepository.save(user));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    // DELETE - Delete student by ID
    @DeleteMapping("/users/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable Long id) {
        return userRepository.findById(id)
            .map(user -> {
                userRepository.deleteById(id);
                return ResponseEntity.ok("User deleted successfully");
            })
            .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("User not found"));
    }

    // HEALTH CHECK - For Kubernetes liveness probe
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Backend is healthy!");
    }
}
