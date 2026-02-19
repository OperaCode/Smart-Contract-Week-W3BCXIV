// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SchoolManagement {


    address public admin;

    mapping(uint16 => uint256) public levelFee;

    uint256 public studentCount;
    uint256 public staffCount;

    // Students storage
    mapping(uint256 => Student) private students;
    uint256[] private studentIds;

    // Staff storage
    mapping(uint256 => Staff) private staffs;
    uint256[] private staffIds;


    struct Student {
        uint256 id;
        string name;
        uint16 level;
        address wallet;

        bool feesPaid;
        uint256 feesPaidAt;
        uint256 totalFeesPaid;
    }

    struct Staff {
        uint256 id;
        string name;
        string role;
        address wallet;

        uint256 salaryWei;
        bool salaryPaid;
        uint256 salaryPaidAt;
        uint256 totalSalaryPaid;
    }


    event LevelFeeUpdated(uint16 level, uint256 feeWei);

    event StudentRegistered(
        uint256 indexed studentId,
        string name,
        uint16 level,
        address indexed wallet,
        uint256 feePaid,
        uint256 paidAt
    );

    event StudentFeeStatusUpdated(
        uint256 indexed studentId,
        bool feesPaid,
        uint256 paidAt,
        uint256 amount
    );

    event StaffRegistered(
        uint256 indexed staffId,
        string name,
        string role,
        address indexed wallet,
        uint256 salaryWei
    );

    event StaffSalaryPaid(
        uint256 indexed staffId,
        address indexed wallet,
        uint256 amount,
        uint256 paidAt
    );

    event Withdrawn(address indexed to, uint256 amount);

   
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }


    constructor() {
        admin = msg.sender;

        levelFee[100] = 1 ether;
        levelFee[200] = 2 ether;
        levelFee[300] = 3 ether;
        levelFee[400] = 4 ether;
    }


    function setLevelFee(uint16 level, uint256 feeWei) external onlyAdmin {
        require(_isValidLevel(level), "Invalid level");
        levelFee[level] = feeWei;
        emit LevelFeeUpdated(level, feeWei);
    }


    function registerStudent(
        string calldata name,
        uint16 level,
        address wallet
    ) external payable {
        require(wallet != address(0), "Zero wallet");
        require(_isValidLevel(level), "Invalid level");

        uint256 fee = levelFee[level];
        require(fee > 0, "Fee not set");
        require(msg.value == fee, "Incorrect fee");

        studentCount++;
        uint256 id = studentCount;

        students[id] = Student({
            id: id,
            name: name,
            level: level,
            wallet: wallet,
            feesPaid: true,
            feesPaidAt: block.timestamp,
            totalFeesPaid: msg.value
        });

        studentIds.push(id);

        emit StudentRegistered(id, name, level, wallet, msg.value, block.timestamp);
    }

    function updateStudentFeeStatus(uint256 studentId, bool paid) external onlyAdmin {
        Student storage s = students[studentId];
        require(s.id != 0, "Student not found");

        s.feesPaid = paid;
        s.feesPaidAt = paid ? block.timestamp : 0;

        emit StudentFeeStatusUpdated(studentId, paid, s.feesPaidAt, 0);
    }

    function getStudent(uint256 studentId) external view returns (Student memory) {
        Student memory s = students[studentId];
        require(s.id != 0, "Student not found");
        return s;
    }

    function getAllStudentIds() external view returns (uint256[] memory) {
        return studentIds;
    }


    function registerStaff(
        string calldata name,
        string calldata role,
        address wallet,
        uint256 salaryWei
    ) external onlyAdmin {
        require(wallet != address(0), "Zero wallet");
        require(salaryWei > 0, "Salary must be > 0");

        staffCount++;
        uint256 id = staffCount;

        staffs[id] = Staff({
            id: id,
            name: name,
            role: role,
            wallet: wallet,
            salaryWei: salaryWei,
            salaryPaid: false,
            salaryPaidAt: 0,
            totalSalaryPaid: 0
        });

        staffIds.push(id);

        emit StaffRegistered(id, name, role, wallet, salaryWei);
    }

    function payStaffSalary(uint256 staffId) external onlyAdmin {
        Staff storage st = staffs[staffId];
        require(st.id != 0, "Staff not found");

        uint256 amount = st.salaryWei;
        require(address(this).balance >= amount, "Insufficient balance");

        st.salaryPaid = true;
        st.salaryPaidAt = block.timestamp;
        st.totalSalaryPaid += amount;

        (bool ok, ) = st.wallet.call{value: amount}("");
        require(ok, "Transfer failed");

        emit StaffSalaryPaid(staffId, st.wallet, amount, block.timestamp);
    }

    function getStaff(uint256 staffId) external view returns (Staff memory) {
        Staff memory st = staffs[staffId];
        require(st.id != 0, "Staff not found");
        return st;
    }

    function getAllStaffIds() external view returns (uint256[] memory) {
        return staffIds;
    }


    receive() external payable {}

    function withdraw(uint256 amount, address payable to) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool ok, ) = to.call{value: amount}("");
        require(ok, "Withdraw failed");

        emit Withdrawn(to, amount);
    }

// helper function for the levels
    function _isValidLevel(uint16 level) internal pure returns (bool) {
        return (level == 100 || level == 200 || level == 300 || level == 400);
    }
}
