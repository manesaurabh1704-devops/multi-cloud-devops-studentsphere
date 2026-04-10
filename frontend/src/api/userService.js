import axios from "axios";

const BASE_URL = import.meta.env.VITE_API_URL;

// GET all students
export const fetchUsers = async () => {
  const response = await axios.get(`${BASE_URL}/users`);
  return response.data;
};

// POST - Register new student
export const registerUser = async (userData) => {
  const response = await axios.post(`${BASE_URL}/register`, userData);
  return response.data;
};

// PUT - Update student by ID
export const updateUser = async (id, userData) => {
  const response = await axios.put(`${BASE_URL}/users/${id}`, userData);
  return response.data;
};

// DELETE - Delete student by ID
export const deleteUser = async (id) => {
  await axios.delete(`${BASE_URL}/users/${id}`);
};

// GET - Backend health check
export const checkHealth = async () => {
  const response = await axios.get(`${BASE_URL}/health`);
  return response.data;
};