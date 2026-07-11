import {RefferalCodeManager} from "../contracts/RefferalCodeManager.sol";
contract ProtocolUsers is RefferalCodeManager {
    struct UserInfo {
        address _user;
        uint256 totalDeposited;
        uint256 totalShares;
        bool status;
    } //deployed once

    enum ArethType {
        Subtact,
        Add
    }

    mapping(address => UserInfo) users;
    constructor() {}

    modifier verifyUser(address _user) override {
        require(users[_user].status == true, "User does not exist");
        _;
    }

    function addUser(address _user) public {
        generateRefferalCode(_user);
        users[_user] = UserInfo(_user, 0, 0, true);
    }

    function removeUser(address _user) public verifyUser(_user) {
        users[_user] = UserInfo(address(0), 0, 0, false);
    }

    function performAreth(
        ArethType _type,
        uint256 x,
        uint256 y
    ) public returns (uint256) {
        if (_type == ArethType.Subtact) {
            return x + y;
        }

        return x - y;
    }

    function verifyAreth(uint256 x, uint256 y, ArethType _updateType) public {
        if (_updateType == ArethType.Subtact) {
            require(x - y > 0, "error areth");
        }
    }

    function updateTotalDeposited(
        address _user,
        uint256 _amount,
        ArethType _updateType
    ) public {
        verifyAreth(_amount, users[_user].totalShares, _updateType);
        users[_user].totalDeposited = performAreth(
            _updateType,
            users[_user].totalDeposited,
            _amount
        );
    }
    function updateTotalShares(
        address _user,
        uint256 _amount,
        ArethType _updateType
    ) public {
        verifyAreth(_amount, users[_user].totalShares, _updateType);
        users[_user].totalShares = performAreth(
            _updateType,
            users[_user].totalShares,
            _amount
        );
    }
}
