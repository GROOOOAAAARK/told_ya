use core::traits::TryInto;
use core::array::ArrayTrait;

use told_ya::{Event_, Prediction};
use told_ya::{IToldYaDispatcher, IToldYaDispatcherTrait};
// use told_ya_tests::utils::{deploy_contract, deploy_erc20};

use openzeppelin::access::ownable::interface::{IOwnable, IOwnableDispatcher, IOwnableDispatcherTrait};
use openzeppelin::token::erc20::interface::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{declare, cheatcodes::{contract_address_const}, start_cheat_caller_address, ContractClassTrait};
use starknet::ContractAddress;

fn deploy_contract(name: ByteArray) -> (ContractAddress, IToldYaDispatcher, ContractAddress) {
    let contract = declare(name).unwrap();
    let owner: ContractAddress = contract_address_const::<'owner'>();
    let owner_felt: felt252 = owner.into();
    let mut calldata: Array<felt252> = ArrayTrait::new();
    calldata.append(owner_felt);

    let (contract_address, _,) = contract.deploy(@calldata).unwrap();

    let dispatcher = IToldYaDispatcher { contract_address: contract_address };

    (contract_address, dispatcher, owner)
}

fn deploy_erc20(recipient: ContractAddress) -> (ContractAddress, IERC20Dispatcher) {
    let name: felt252 = 'ERC20_test';
    let symbol: felt252 = 'ERC20T';
    let initial_supply: u256 = 100;

    let mut calldata: Array<felt252> = ArrayTrait::new();
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(initial_supply.low.into());
    calldata.append(initial_supply.high.into());
    calldata.append(recipient.into());

    let contract = declare("openzeppelin::token::erc20::ERC20Upgradeable").unwrap();
    let (address, _) = contract.deploy(@calldata).unwrap();

    let dispatcher = IERC20Dispatcher { contract_address: address };

    (address, dispatcher)
}

#[test]
fn test_events() {
    let (contract_address, dispatcher, owner): (ContractAddress, IToldYaDispatcher, ContractAddress) = deploy_contract("ToldYa");

    // Event
    let name: felt252 = 'test_event';
    let predictions_deadline: felt252 = '2024-08-24';
    let event_datetime: felt252 = '2024-08-25';
    let type_: felt252 = 'football';

    start_cheat_caller_address(contract_address, owner);
    let create_event_response = dispatcher.create_event(name, predictions_deadline, event_datetime, type_);

    let new_event_identifier = create_event_response.identifier;

    let read_events_response = dispatcher.get_events();

    assert(read_events_response.at(0).identifier == @new_event_identifier, 'Invalid identifier');
    assert(read_events_response.at(0).name == @name, 'Invalid name');
    assert(read_events_response.at(0).predictions_deadline == @predictions_deadline, 'Invalid predictions_deadline');
    assert(read_events_response.at(0).event_datetime == @event_datetime, 'Invalid datetime');
    assert(read_events_response.at(0).type_ == @type_, 'Invalid _type');
}

#[test]
fn test_predictions() {
    let (contract_address, dispatcher, owner): (ContractAddress, IToldYaDispatcher, ContractAddress) = deploy_contract("ToldYa");

    // Event
    let name: felt252 = 'test_event';
    let predictions_deadline: felt252 = '2024-08-24';
    let event_datetime: felt252 = '2024-08-25';
    let type_: felt252 = 'football';

    let buyer: ContractAddress = contract_address_const::<'buyer'>();
    let (erc20_address, _erc20_dispatcher): (ContractAddress, IERC20Dispatcher) = deploy_erc20(buyer);
    let buyingToken: ContractAddress = erc20_address;
    let buyPrice: u256 = 3;

    start_cheat_caller_address(contract_address, owner);
    let create_event_response = dispatcher.create_event(name, predictions_deadline, event_datetime, type_);

    let new_event_identifier = create_event_response.identifier;

    let user: ContractAddress = contract_address_const::<'user'>();
    // Prediction
    let value: felt252 = 'test_value';

    start_cheat_caller_address(contract_address, user);

    let create_prediction_response = dispatcher.create_prediction(new_event_identifier, value, buyingToken, buyPrice);

    let new_prediction_identifier = create_prediction_response.identifier;

    let read_predictions_response = dispatcher.get_predictions();

    assert(read_predictions_response.at(0).identifier == @new_prediction_identifier, 'Invalid identifier');
    assert(read_predictions_response.at(0).event_identifier == @new_event_identifier, 'Invalid event_identifier');
    assert(read_predictions_response.at(0).value == @value, 'Invalid value');

    start_cheat_caller_address(contract_address, buyer);

    let buy_prediction_response = dispatcher.buy_prediction(new_prediction_identifier);

    let user_bought_predictions = dispatcher.get_user_bought_predictions(owner);

    assert(user_bought_predictions.at(0).identifier == @buy_prediction_response.identifier, 'Invalid identifier');
    assert(user_bought_predictions.at(0).event_identifier == @new_event_identifier, 'Invalid event_identifier');
    assert(user_bought_predictions.at(0).value == @value, 'Invalid value');
    assert(user_bought_predictions.at(0).creator == @owner, 'Invalid creator');
    assert(user_bought_predictions.at(0).buyingToken == @buyingToken, 'Invalid buyingToken');
    assert(user_bought_predictions.at(0).buyingPrice == @buyPrice, 'Invalid buyingPrice');
    //TODO: verify erc20 balance change for both buyer and prediction creator

}
