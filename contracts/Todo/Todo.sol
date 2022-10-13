// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TodoApp {
    struct Todo {
        string title;
        string description;
        bool isCompleted;
    }

    uint taskId = 0;
    mapping(address => Todo[]) userToTasks;

    event addTask(address user, uint id);
    event taskDone(uint id, bool isCompleted);

    function createTask(string calldata _title, string calldata _description) 
    external {
        userToTasks[msg.sender].push(Todo(
            _title,
            _description,
            false
        ));
        emit addTask(msg.sender, taskId++);
    }

    function getTask(uint _taskId) 
    external view returns (Todo memory) {
       Todo storage task = userToTasks[msg.sender][_taskId];
       return task;
    }

    function toogleTaskStatus(uint _taskId, bool _status) 
    external{
        userToTasks[msg.sender][_taskId].isCompleted = _status;
        emit taskDone(_taskId, true);
    }

    function deleteTask(uint _taskId) 
    external{
        delete userToTasks[msg.sender][_taskId];
    } 

}
