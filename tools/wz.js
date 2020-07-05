const RAM =[
	4,	// WZ 0
	13,	// WZ 1
	22,	// WZ 2
	31,	// WZ 3
	37,	// WZ 4
	45,	// WZ 5
	77,	// WZ 6
	91,	// WZ 7
	33,	// ADDR da codificare
	-1	// OUTPUT valore codificato
];
const EXPECTED = 180;

// -----------

const ADDR = 8;
const OUTPUT = 9;
const NWZ = 8;
const DWZ = 4;

function encode() {
	// for each working zone
	for (let i = 0; i < NWZ; i++) {
		let diff = RAM[ADDR] - RAM[i];
		// calculate distance from base address
		if (diff >= 0 && diff < DWZ) {
			// encode
			RAM[OUTPUT] = (1 << 7) | (i << 4) | (1 << diff);
			return;
		}
	}

	// default
	RAM[OUTPUT] = RAM[ADDR];
}

function binary(value) {
	let arr = value.toString(2).split('');
	arr.splice(4, 0, '-');
	arr.splice(1, 0, '-');
	return arr.join('');
}

// -----------

encode();

console.log("expected:", EXPECTED, ':', binary(EXPECTED));
console.log("output:", RAM[OUTPUT], ':', binary(RAM[OUTPUT]));