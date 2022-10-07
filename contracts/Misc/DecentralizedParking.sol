// SPDX-License-Identifier: MIT
// This is a smart contract used for decentralized parking
pragma solidity ^0.8.9;

contract DecentralizedParking {
  Parking[] public parkings;

  struct Parking {
    address owner;
    address renter;
    uint256 rentPrice;
    uint256 parkingPrice;
    uint256 rentDuration;
    uint256 rentExpiration;
  }

  address private nullAddress = 0x0000000000000000000000000000000000000000;

  event ParkingAdded(address indexed _owner, uint256 parkingID);

  modifier validId(uint256 _indexParking) {
    require(_indexParking < parkings.length, 'Invalid parking ID');
    _;
  }

  modifier ownerOnly(uint256 _indexParking) {
    require(getOwnerByIndex(_indexParking) == msg.sender, 'You are not the owner of this parking');
    _;
  }

  // GETTERS

  function getAvailability(uint256 _indexParking) public view validId(_indexParking) returns (bool) {
    return (block.timestamp >= parkings[_indexParking].rentExpiration);
  }

  function getRentPriceByIndex(uint256 _indexParking) public view validId(_indexParking) returns (uint256) {
    return parkings[_indexParking].rentPrice;
  }

  function getOwnerByIndex(uint256 _indexParking) public view validId(_indexParking) returns (address) {
    return parkings[_indexParking].owner;
  }

  function getRenterByIndex(uint256 _indexParking) public view validId(_indexParking) returns (address) {
    return parkings[_indexParking].renter;
  }

  function getParkingPriceByIndex(uint256 _indexParking) public view validId(_indexParking) returns (uint256) {
    return parkings[_indexParking].parkingPrice;
  }

  function getRentDurationByIndex(uint256 _indexParking) public view validId(_indexParking) returns (uint256) {
    return parkings[_indexParking].rentDuration;
  }

  function getRentExpirationByIndex(uint256 _indexParking) public view validId(_indexParking) returns (uint256) {
    return parkings[_indexParking].rentExpiration;
  }

  function getParkings() public view returns (Parking[] memory) {
    return parkings;
  }

  // SETTERS

  function setRentPrice(uint256 _rentPrice, uint256 _indexParking)
    public
    payable
    validId(_indexParking)
    ownerOnly(_indexParking)
  {
    parkings[_indexParking].rentPrice = _rentPrice;
  }

  function setParkingPrice(uint256 _parkingPrice, uint256 _indexParking)
    public
    payable
    validId(_indexParking)
    ownerOnly(_indexParking)
  {
    parkings[_indexParking].parkingPrice = _parkingPrice;
  }

  function setRentDuration(uint256 _rentDuration, uint256 _indexParking)
    public
    payable
    validId(_indexParking)
    ownerOnly(_indexParking)
  {
    parkings[_indexParking].rentDuration = _rentDuration * 1 days;
  }

  function addParkingSpot(
    address _owner,
    uint256 _rentPrice,
    uint256 _ParkingPrice,
    uint256 _rentDuration
  ) external {
    parkings.push(Parking(_owner, nullAddress, _rentPrice, _ParkingPrice, _rentDuration * 1 days, 0));
    emit ParkingAdded(msg.sender, parkings.length - 1);
  }

  function RentParking(uint256 _indexParking) public payable validId(_indexParking) {
    uint256 _rentPrice = getRentPriceByIndex(_indexParking);
    require(getRenterByIndex(_indexParking) != msg.sender, 'You are already renting the parking');
    require(msg.sender != getOwnerByIndex(_indexParking), "You can't rent your own parking");
    require(getAvailability(_indexParking), 'The parking is already in use');
    require(msg.value == _rentPrice, "The amount sent doesn't correspond to the renting price");

    (bool sent, ) = payable(getOwnerByIndex(_indexParking)).call{value: getRentPriceByIndex(_indexParking)}('');
    require(sent, 'Transaction failed');

    parkings[_indexParking].renter = msg.sender;
    parkings[_indexParking].rentExpiration = block.timestamp + parkings[_indexParking].rentDuration;
  }

  function unRentParking(uint256 _indexParking) public payable validId(_indexParking) ownerOnly(_indexParking) {
    require(
      getRentExpirationByIndex(_indexParking) <= block.timestamp,
      'You cannot ask to unRent yet, wait till the contract finishes'
    );
    parkings[_indexParking].renter = nullAddress;
  }

  function buyParking(uint256 _indexParking) public payable validId(_indexParking) {
    require(getOwnerByIndex(_indexParking) != msg.sender, 'You cannot buy your own parking');
    require(msg.value == getParkingPriceByIndex(_indexParking), 'You didnt send the good amount to buy the parking');

    (bool sent, ) = payable(getOwnerByIndex(_indexParking)).call{value: getParkingPriceByIndex(_indexParking)}('');
    require(sent, 'Transaction failed');

    parkings[_indexParking].owner = msg.sender;
  }
}