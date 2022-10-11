// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Admin having extra access
contract Admin{
    
    address admin;

    constructor(){
        admin = msg.sender; 
    }
    modifier onlyAdmin(){
    require(msg.sender == admin);
    _;
    }
}

contract StudentManagment is Admin{
 
   //unique identifier for student
   uint256 studentID;

   // student attributes
   struct Student{
       bool registered;
       string name;
       uint256 year;
       string department;
       bool bookIssued;
       bool defaulter;
   }
   
    // unique identifier for book
    uint256 isbn;
    
    //@ attribute of students that are to be added.
    
    struct Book{
        string name;
        uint256 numBooks;
        uint256 price;
        bool isAdded;
        bool isIssued;
    }
    
    uint256 bookCode;
    
    //mapping bookcode to isbn to Struct Book.
    mapping (uint256 => mapping(uint256 => Book)) public lib;
    
    // mapping ETH address to unique ID to Struct Student.
    mapping(address => mapping(uint256 => Student))public students;
    
    // events related to books.
    event AddBooks (uint256 indexed isbn,string indexed name,uint256 price);
    event RemoveBook (uint256 indexed isbn,uint256 indexed bookCode);
    event BookIssued (uint256 indexed isbn,uint256 indexed bookCode, address studentAddress, uint256 ID);
    
    // events related to Student.
    event Register(uint256 indexed _studentID, address studAdd);
    event Suspended(uint256 indexed  _studentID, address studAdd);
    event Removed(uint256 indexed  _studentID, address studAdd);
    
    // Registration of student setting up attributes. 
    // Accessible to admin of the system only.
    // Student can be registered only Once.
    function register(address _toRegister,uint256 _studentID, string memory _name, 
    uint256 _year, string memory _department) public 
    onlyAdmin 
    returns(bool)
    {
       Student storage s = students[_toRegister][_studentID];
    
       if(s.registered)
       revert("Already Registered");
       students[_toRegister][_studentID] = Student(false,_name, _year, _department,false,false);
       s.registered = true;
       emit Register( _studentID, _toRegister);
       return true;
   }

    // Check for conditions like is the student is registered or not & is the student is a defaulter.
    function isAllowed(address _toCheck,uint256 _studentID)internal view returns(bool)
    {
       Student storage s = students[_toCheck][_studentID];
       if(s.registered || s.defaulter)
       return true;
       else
       return false;
   }
    
    // Only admin is allowed to remove student from the system.
    // delete() will remove all the existing attribute of the student of that particular ETH address and ID.
    function remove(uint256 _studentID,address _toRemove)public onlyAdmin returns(bool) 
    {
        
        Student storage s = students[_toRemove][_studentID];
        
        if(s.registered)
        delete(students[_toRemove][_studentID]);
        else
        revert("No student");
        emit Removed(_studentID, _toRemove);
        return true;
    }
    
    // Admin will suspend the student from the system.
    function suspend(uint256 _studentID, address _toSuspend)public onlyAdmin returns(bool) 
    {
        
        Student storage s = students[_toSuspend][_studentID];
        
        if(s.registered)
        s.defaulter = true;
        else
        revert("No student");
        emit Suspended(_studentID, _toSuspend);
        return true;
    }
   
    // Adding books with unique _isbn number and _bookcode and other attributes of a book.
    // A book  with a unique combination of _isbn and _bookcode can be added only once.
    function addBooks(uint256 _bookCode,uint256 _isbn,string memory _name,uint256 _price)public
    onlyAdmin returns(bool)
    {
        Book storage b = lib[_bookCode][_isbn];
        
        lib[_bookCode][_isbn] = Book(_name,1,_price,true,false);
        if(bookCode == _bookCode && isbn != _isbn)
        b.numBooks++;
        emit AddBooks(_isbn,_name,_price);
        return(true);
    }
    
    // Books issued is added to the address that requested the issue.
    // Checks the availiblity of the requested book.
    // The Book is marked as Issued if the transaction go through.
    function issueBook(uint256 _bookCode, uint256 _isbn, address _requestIssue, uint256 _id)public 
    returns(bool)
    {
        Book storage b = lib[_bookCode][_isbn];
        require(isAllowed(_requestIssue, _id),  "Not allowed to issue ");
        
        if(b.isIssued || (b.numBooks == 0))
        revert("Book is not available");
        b.isIssued = true;
        b.numBooks--;
        emit BookIssued(_isbn,_bookCode, _requestIssue, _id);
        return true;
   }
   
    // TRemove books & all the attributes are deleted.
    // Check that the book isn't issued and there exists a desired book in the system. 
    function removeBooks(uint256 _bookCode,uint256 _isbn)public onlyAdmin returns(bool)
    {
       Book storage b = lib[_bookCode][_isbn];
       
        if(b.isIssued || (b.numBooks == 0))
        revert("No such book Exist in the library");
        delete(lib[_bookCode][_isbn]);
        emit RemoveBook(_bookCode,_isbn);
        return true;
    }
}
