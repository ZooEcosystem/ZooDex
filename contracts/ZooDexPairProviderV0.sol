// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ZooDexPairProviderV0 is Ownable{
    
    address[] listedPairs;
    
    event pairAdded(address pair, address token1, address token2);
    event pairRemoved(address pair);
    
    mapping(address => Pair) tradingPairs;
    
    struct Pair{
        address _token1;
        address _token2;
        bool exists;
        string exchange;
    }
    
    function listPairOnDex(address _pair, address _token1, address _token2, string memory _exchange) public onlyOwner {
        require(!tradingPairs[_pair].exists,"Already exists");
        tradingPairs[_pair]._token1 = _token1;
        tradingPairs[_pair]._token2 = _token2;
        tradingPairs[_pair].exists = true;
        tradingPairs[_pair].exchange = _exchange;
        listedPairs.push(_pair);
        emit pairAdded(_pair,_token1,_token2);
    }
    
    function isListedOnDex(address _pair) public view returns(bool){

        return tradingPairs[_pair].exists;
    } 
    
    function getCoinsInPair(address _pair) public view returns(address, address){
        return (tradingPairs[_pair]._token1, tradingPairs[_pair]._token2);
    }
    
    function getAllListedPairs() public view returns(address[] memory){
        return listedPairs;
    }
    
    function getExchangeOfPair(address _pair) public view returns(string memory){
        return tradingPairs[_pair].exchange;
    }
    
    function removePairFromDex(address _pair) public onlyOwner {
        require(tradingPairs[_pair].exists,"Already removed");
        tradingPairs[_pair].exists = false;
        emit pairRemoved(_pair);
    }
    
}
