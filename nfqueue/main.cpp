#include <cstdlib>
#include <iostream>
#include <iomanip>

#include <time.h>

#include <netinet/in.h>
extern "C" {
  #include <linux/netfilter.h>  /* Defines verdicts (NF_ACCEPT, etc) */
  #include <libnetfilter_queue/libnetfilter_queue.h>
}

using namespace std;

static int Callback(nfq_q_handle *myQueue, struct nfgenmsg *msg,
                    nfq_data *pkt, void *cbData) {
  uint32_t id = 0;
  nfqnl_msg_packet_hdr *header;

  if ((header = nfq_get_msg_packet_hdr(pkt))) {
    id = ntohl(header->packet_id);
  }

  unsigned char *pktData;
  int len = nfq_get_payload(pkt, &pktData);
  if (len) {
    int cursor=-1;

    for (int i = 28; i < len; i++) {
      if (pktData[i]== 0xFF){
        if (pktData[i+1]==0xFF && pktData[i+2]==0xFF && pktData[i+3]==0xFF && pktData[i+4]==0x49){

          cursor=i+5;

          // Skip forward until we have read 4 strings. We have reached the AppID
          unsigned int stringsPassed = 0;
          for (int i = cursor; i < len; i++){
            if (pktData[i] == 0x00){
              stringsPassed += 1;

              if ( stringsPassed == 4 ) {
                cursor = i+1;
                break;
              }
            }
          }

          // Skip forward 2 bytes. We've now reached players.
          cursor += 2;

          // Let's tell the user.
          if ( ( (int) pktData[cursor] ) < 8 ){
            pktData[cursor]=8;
            pktData[0x1a]=0;
            pktData[0x1b]=0;

            nfq_set_verdict(myQueue, id, NF_ACCEPT, len, pktData);
          }

          break;
        } else if (pktData[i+1]==0xFF && pktData[i+2]==0xFF && pktData[i+3]==0xFF && pktData[i+4]==0x44) {
          cursor=i+5;

          // Read the amount of players.
          int players = (int) pktData[i];

          if (players >= 0 && players < 8){
            pkgData[i]=8;
            pkgData[0x1a]=0;
            pkgData[0x1b]=0;
          }

          break;
        }
      }
    }
  }

  return nfq_set_verdict(myQueue, id, NF_ACCEPT, 0, NULL);
}

int main(int argc, char **argv) {

  struct nfq_handle *nfqHandle;
  struct nfq_q_handle *myQueue;
  struct nfnl_handle *netlinkHandle;

  int fd, res;
  char buf[4096];

  cout << "Starting NFQUEUE filter." << endl;

  if (!(nfqHandle = nfq_open())) {
    cerr << "Error in nfq_open()" << endl;
    exit(-1);
  }

  if (nfq_unbind_pf(nfqHandle, AF_INET) < 0) {
    cerr << "Error in nfq_unbind_pf()" << endl;
    exit(1);
  }

  if (nfq_bind_pf(nfqHandle, AF_INET) < 0) {
    cerr << "Error in nfq_bind_pf()" << endl;
    exit(1);
  }

  if (!(myQueue = nfq_create_queue(nfqHandle,  0, &Callback, NULL))) {
    cerr << "Error in nfq_create_queue()" << endl;
    exit(1);
  }

  if (nfq_set_mode(myQueue, NFQNL_COPY_PACKET, 0xffff) < 0) {
    cerr << "Could not set packet copy mode" << endl;
    exit(1);
  }

  netlinkHandle = nfq_nfnlh(nfqHandle);
  fd = nfnl_fd(netlinkHandle);

  while ((res = recv(fd, buf, sizeof(buf), 0)) && res >= 0) {
    nfq_handle_packet(nfqHandle, buf, res);
  }

  nfq_destroy_queue(myQueue);

  nfq_close(nfqHandle);

  return 0;
}
