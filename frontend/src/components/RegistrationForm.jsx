import React from "react";
import { useRegistrationForm } from "../hooks/useRegistrationForm";
import "./RegistrationForm.css";
import Modal from "./Modal";

const RegistrationForm = () => {
  const {
    name,
    setName,
    email,
    setEmail,
    course,
    setCourse,
    studentClass,
    setStudentClass,
    percentage,
    setPercentage,
    branch,
    setBranch,
    mobileNumber,
    setMobileNumber,
    showModal,
    setShowModal,
    handleSubmit,
    handleDelete,
    limitedUsers,
  } = useRegistrationForm();

  return (
    <div className="registration-container">
      <h2 style={{ color: "#ff8000" }}>
        StudentSphere <span style={{ color: "#ffff" }} className="heading">Student Registration</span>
      </h2>

      <form onSubmit={handleSubmit} className="form-container">
        <input type="text" placeholder="Name" value={name} onChange={(e) => setName(e.target.value)} className="form-input" required />
        <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} className="form-input" required />
        <input type="text" placeholder="Course" value={course} onChange={(e) => setCourse(e.target.value)} className="form-input" required />
        <input type="text" placeholder="Highest Education" value={studentClass} onChange={(e) => setStudentClass(e.target.value)} className="form-input" required />
        <input type="number" placeholder="Percentage" value={percentage} onChange={(e) => setPercentage(e.target.value)} className="form-input" required />
        <input type="text" placeholder="Branch Or Stream" value={branch} onChange={(e) => setBranch(e.target.value)} className="form-input" required />
        <input type="text" placeholder="Mobile Number" value={mobileNumber} onChange={(e) => setMobileNumber(e.target.value)} className="form-input" required />
        <button type="submit" className="submit-button">Register</button>
      </form>

      <h3>Registered Students</h3>
      <table className="user-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Course</th>
            <th>Class</th>
            <th>Percentage</th>
            <th>Branch</th>
            <th>Mobile</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {limitedUsers.length > 0 ? (
            limitedUsers.map((user) => (
              <tr key={user.id}>
                <td>{user.name}</td>
                <td>{user.email}</td>
                <td>{user.course}</td>
                <td>{user.studentClass}</td>
                <td>{user.percentage}</td>
                <td>{user.branch}</td>
                <td>{user.mobileNumber}</td>
                <td>
                  <button onClick={() => handleDelete(user.id)} className="delete-button">
                    Delete
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="8" className="no-users">No students registered yet</td>
            </tr>
          )}
        </tbody>
      </table>

      {showModal && <Modal message="Student registered successfully!" onClose={() => setShowModal(false)} />}
    </div>
  );
};

export default RegistrationForm;