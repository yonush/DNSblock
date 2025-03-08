## Intro
Toggle DNS blocking on Pi-hole using the new API of Pi-hole v6. This was an experiment in learning Nim code. I am sure this functioanlity can be written in other languages like Go or C/C++. There is nothing special in the code, just written for convenience.

The pi-hole app password can be setup [here over HTTP](http://pi.hole/admin/settings/api) or [here over HTTPS](https://pi.hole/admin/settings/api)

**usage**
``` sh
	DNSblock [pihole app password] [state]

```

## Dev notes

- [pihole API documentation](https://docs.pi-hole.net/api/)
- The api docs can be found within you installation [here over HTTP](http://pi.hole/api/docs/) or [here over HTTPS](https://pi.hole/api/docs/)
- Code is writting using Nim 2.x to create a small compact 300KB binary. The code only uses the standard library and no additional libraries
- OFF.cmd and On.cmd are used for testing the binary
- cmp.cmd is used to compile the binary for release and run.cmd is just to run and test the code
- pihole.py was from testing the API and is not considered the same as the DNSblock code. The Nim version is a result of the pihole.py API testing.
- Being written in Nim means it can be compiled for other OS's - not yet tested.
