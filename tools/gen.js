const fs = require('fs');

const SET_SIZE = 10;
const SET_COUNT = 100000;
const OUTPUT_FILE = 'ram_values.txt';

const NWZ = 8;
const DWZ = 4;

function generateTests() {
    try {
        fs.writeFileSync(OUTPUT_FILE, '')
    }
    catch (err) {
        throw err;
    }

    for (let s = 0; s < SET_COUNT; s++) {
        generateSet(s);
    }
}

function generateSet(s) {
    let RAM = [];
    let i = 0;
    while (i < NWZ) {
        let wz = gen();

        let valid = true;
        for (let j = 0; j < RAM.length; j++) {
            if (contains(RAM[j], wz)) {
                valid = false;
            }
        }

        if (valid) {
            RAM.push(wz);
            i++;
        }
    }

    for (let t = 0; t < SET_SIZE; t++) {
        let test = RAM.map((x) => x);
        let addr = gen();
        let encoded = encode(RAM, addr);
        test.push(addr);
        test.push(0);
        test.push(encoded);

        let output = test.join('\n');
        if (s < SET_COUNT-1 || t < SET_SIZE-1) {
            output += '\n';
        }

        try {
            fs.appendFileSync(OUTPUT_FILE, output);
        }
        catch (err) {
            throw err;
        }
    }
}

function gen() {
    return Math.floor(Math.random() * 125); // 0 - 124
}

function contains(elem, wz) {
    return (Math.abs(elem - wz) < 3);
}

function encode(RAM, addr) {
    // for each working zone
	for (let i = 0; i < NWZ; i++) {
		let diff = addr - RAM[i];
		// calculate distance from base address
		if (diff >= 0 && diff < DWZ) {
			// encode
			return (1 << 7) | (i << 4) | (1 << diff);
		}
	}

	// default
	return addr;
}


generateTests();