use core::traits::TryInto;
use core::array::ArrayTrait;

use told_ya::{Event_, Prediction};
use told_ya::{IToldYaDispatcher, IToldYaDispatcherTrait};

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
fn test_create_prediction() {
    let contract_address = deploy_contract("ToldYa");

    let dispatcher = IToldYaDispatcher { contract_address };

    // Event
    let name: felt252 = 'test_event';
    let predictions_deadline: felt252 = '2024-08-24';
    let event_datetime: felt252 = '2024-08-25';
    let type_: felt252 = 'football';

    let create_event_response = dispatcher.create_event(name, predictions_deadline, event_datetime, type_);

    let new_event_identifier = create_event_response.identifier;

    let read_events_response = dispatcher.get_events();

    assert(read_events_response.at(0).identifier == @new_event_identifier, 'Invalid identifier');
    assert(read_events_response.at(0).name == @name, 'Invalid name');
    assert(read_events_response.at(0).predictions_deadline == @predictions_deadline, 'Invalid predictions_deadline');
    assert(read_events_response.at(0).event_datetime == @event_datetime, 'Invalid datetime');
    assert(read_events_response.at(0).type_ == @type_, 'Invalid _type');

    // Prediction
    let value: felt252 = 'test_value';

    let create_prediction_response = dispatcher.create_prediction(new_event_identifier, value);

    let new_prediction_identifier = create_prediction_response.identifier;

    let read_predictions_response = dispatcher.get_predictions();

    assert(read_predictions_response.at(0).identifier == @new_prediction_identifier, 'Invalid identifier');
    assert(read_predictions_response.at(0).event_identifier == @new_event_identifier, 'Invalid event_identifier');
    assert(read_predictions_response.at(0).value == @value, 'Invalid value');
}