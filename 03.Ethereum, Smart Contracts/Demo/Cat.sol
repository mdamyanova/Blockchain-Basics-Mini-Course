pragma solidity ^0.4.24;

contract Cat {
    struct AdoptionCat {
        string name;
        uint8 age;
        string gender;
        string town;
        string descr;
        string imageHash;
        string organization;
        address catOwner;
        bool isAdopted;
    }
    
    address private owner;
    string[] private organizations;
    
    mapping(string => AdoptionCat[]) private adoptionCats;
    mapping(address => uint) private donations;
    
    uint public allDonations;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwner() {
        require(owner == msg.sender, "Not the contract owner");
        _;
    }
    
    modifier catExists(string memory _organization, uint _index) {
        require(_index < adoptionCats[_organization].length, "Cat does not exist");
        _;
    }
    
    modifier canAdopt(string memory _organization, uint _index) {
        require(!adoptionCats[_organization][_index].isAdopted, "Cat already adopted");
        _;
    }
    
    event Donation(address indexed _from, uint _amount);
    event Adopt(address indexed _owner);
    
    function donate() public payable {
        require(msg.value > 0, "Donation must be greater than 0");
        donations[msg.sender] += msg.value;
        allDonations += msg.value;
        emit Donation(msg.sender, msg.value);
    }
    
    function getDonations(address _donor) public view returns (uint) {
        return donations[_donor];
    }
    
    function info(string memory _organization, uint _index) 
      public view catExists(_organization, _index)
      returns (string memory, uint8, string memory, string memory, string memory, string memory) {
        AdoptionCat storage cat = adoptionCats[_organization][_index];
        return (cat.name, cat.age, cat.gender, cat.town, cat.descr, cat.organization);
    }
    
    function isAdopted(string memory _organization, uint _index) 
      public view catExists(_organization, _index)
      returns (bool) {
        return adoptionCats[_organization][_index].isAdopted;
    }
    
    function imageHash(string memory _organization, uint _index)
      public view catExists(_organization, _index)
      returns (string memory) {
          return adoptionCats[_organization][_index].imageHash;
    }
    
    function catOwner(string memory _organization, uint _index)
      public view catExists(_organization, _index)
      returns (address) {
          return adoptionCats[_organization][_index].catOwner;
    }
    
    function add(string memory _name, uint8 _age, string memory _gender, string memory _town,
        string memory _descr, string memory _imageHash, string memory _organization) public {
        
        // Add new organization if not already added
        if (adoptionCats[_organization].length == 0) {
            organizations.push(_organization);
        }
        
        // Create and add new cat
        adoptionCats[_organization].push(AdoptionCat({
            name: _name,
            age: _age,
            gender: _gender,
            town: _town,
            descr: _descr,
            imageHash: _imageHash,
            organization: _organization,
            catOwner: msg.sender,
            isAdopted: false
        }));
    }
    
    function adopt(string memory _organization, uint _index) 
    public catExists(_organization, _index) canAdopt(_organization, _index) {
        AdoptionCat storage cat = adoptionCats[_organization][_index];
        cat.isAdopted = true;
        cat.catOwner = msg.sender;
        emit Adopt(msg.sender);
    }
}
