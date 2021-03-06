// SPDX-License-Identifier: Unlicansed
pragma solidity ^0.8.7;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// ----------------------------------------------------------------------------

// ERC20 = Ethereum Request Command, Ethereum ağına bağlı tokenler için kullanılıyor
// 6 "Function" ve 2 "Event" içeren bir "interface" barındırıyor. Kontratı yazarken bu fonksiyonları "override" etmemiz gerekiyor.
// Transfer edilebilir bir token için hepsini kullanmaya gerek yok ilk üç fonksiyon yeterli?
// https://ethereum.org/en/developers/docs/standards/tokens/erc-20/ Sitede 3 adet isteğe bağlı fonksiyon daha var?

interface ERC20Interface {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

// Hata almamak için interface'de tanımlı olan her şeyi "override" etmemiz gerekiyor?
// Burdaki çoğu şey standart ve anlamama gerek yok sadece böyle yapıldığını bilmek gerekiyor.
contract MyFirstToken is ERC20Interface {

    string public name = "MyFirstERC20Token";
    string public symbol = "MFET";
    uint public decimals = 0;   // Token için virgülden sonra gelen max sayı sayısı? Genelde 18 oluyor.
    uint public override totalSupply;   // "totalSupply" için fonksiyon tanımlamak yerine böyle yaptık

    address public founder; // Tokenlerin ilk başta gideceği adresi tanımladık. Zorunlu değil ama kullanışlı?
    mapping(address => uint) public balances;   // Her adreste varsayılan olarak 0 token tanımlı oluyor. Hangi adreste ne kadar token var depolayabilmek için tanımlıyoruz.

    // Kendi hesabındaki tokenlerin bir kısmını başkasının harcamasına izin vermek?
    mapping(address => mapping(address => uint)) allowed;
    // 0x111... (owner) allows 0x222... (the spender) --- 100 tokens
    // allowed[0x111][0x222] = 100;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;    // Bütün tokenleri "founder" a aktardık.
    }

    // Herhangi bir adresin elinde kaç token var görmek için kullanılan fonksiyon.
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer yapmak için gereken fonksiyon.
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value);    // Elinde bulunan tokenden fazla token göderememesi için

        balances[_to] += _value;
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(allowed[_from][_to] >= _value);
        require(balances[_from] >= _value);

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][_to] -= _value;

        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(_value > 0);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
}
