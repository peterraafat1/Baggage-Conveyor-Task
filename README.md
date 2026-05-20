Baggage Conveyor Belt System
Architecture Overview
This system utilizes a Server-Authoritative, Client-Rendered architecture to handle the continuous movement of multiple unanchored parts. By avoiding server-owned physics for the bags, the network receive rate is heavily optimized, keeping data transfer under 4 KB/s.

System Workflow
Network Efficiency: Replicating the CFrame of up to 30 moving parts continuously causes severe network spikes. Instead, the server fires a single RemoteEvent to all clients with only the essential metadata upon bag creation.

Server Responsibilities: The server generates precise metadata for each bag, manages the active bag count, and handles UI interval logic.

Client Responsibilities: Upon receiving the metadata, clients instantiate a local part and execute all spatial movement and animations smoothly using TweenService.

Memory Management: The server automatically drops the bag from its memory once the calculated transit time elapses, eliminating the need for the client to ping the server back.

Interaction: Clicks are processed via client-side raycasting. Upon a successful hit, the client fires a remote to the server passing only the bag's unique UUID string.

Matchmaking System Design
This is a polished version of your answer, structured to highlight the logic flow for an interviewer or technical lead.

1. Data Structure & Queueing
I would build the system around MemoryStoreService utilizing a SortedMap. When a party queues up, their Party ID, average MMR, and party size are assigned to a specific bucket (e.g., 1v1, 2v2, 3v3). The sorting key is their MMR, which allows for highly efficient, range-based queries.

2. Matchmaker Worker & Polling
A dedicated matchmaker worker polls the SortedMap periodically using GetRangeAsync. To prevent multiple servers from overlapping or double-booking players, the worker relies on a locking mechanism within MemoryStoreService.

3. MMR Expansion Logic
During a poll, the worker searches for parties with similar MMRs within an acceptable delta. If parties remain in the queue too long, this acceptable MMR delta dynamically expands based on the elapsed time (CurrentTime - TimeJoined), ensuring players are not trapped in dead queues.

4. Server Reservation
Once a valid match is formed, the worker reserves a dedicated game server using TeleportService:ReserveServer and generates a unique Match ID.

5. Cross-Server Communication
The match details and the ReservedServerAccessCode are broadcasted across the network via MessagingService. The specific lobby servers hosting the queued players receive this message, prompt the clients, and teleport them directly into the reserved instance.
