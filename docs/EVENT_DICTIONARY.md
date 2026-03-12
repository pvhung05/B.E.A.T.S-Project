# B.E.A.T.S. Event Payload Dictionary
Bất cứ thay đổi nào sẽ dẫn đến lỗi ClassCastException

Để việc dev giữa CoreEngineer, TechArt và Frontend được diễn ra song song trong khi không cần biết bên kia code như thế nào thì sẽ cần một protocol chung cho các sự kiện xảy ra. 

Mình đã tạo sẵn một số cái sẽ cần, mỗi PR nếu mình thấy có thay đổi trong EventType nhưng lại **không thêm docs cho event đó** thì mình sẽ từ chối merge.

| `EventType`                      | Payload `[0]`                                                     | Payload `[1]`                              | Payload `[2]`            | Payload `[3]`                                      |
| :------------------------------- | :---------------------------------------------------------------- | :----------------------------------------- | :----------------------- | :------------------------------------------------- |
| **`EVENT_APP_PAUSE`**            | `null`                                                            | `null`                                     | `null`                   | `null`                                             |
| **`EVENT_APP_RESUME`**           | `null`                                                            | `null`                                     | `null`                   | `null`                                             |
| **`EVENT_UI_TOOL_SELECTED`**     | `String` (Tool ID: `"SPAWN_ALGAE"`, `"SPAWN_SARDINE"`, `"CULL"`)  | `null`                                     | `null`                   | `null`                                             |
| **`EVENT_ENV_PARAM_CHANGED`**    | `String` (Param: `"TEMP"`, `"POLLUTION"`)                         | `Float` (Normalized value: `0.0` to `1.0`) | `null`                   | `null`                                             |
| **`EVENT_ENTITY_SPAWN_REQUEST`** | `String` (Entity ID: `"ALGAE"`, `"SARDINE"`, `"SHARK"`, `"CRAB"`) | `Float` (Target X coord)                   | `Float` (Target Y coord) | `null`                                             |
| **`EVENT_ENTITY_DESTROYED`**     | `String` (Entity ID that died)                                    | `Float` (Death X coord)                    | `Float` (Death Y coord)  | `String` (Cause: `"EATEN"`, `"STARVED"`, `"CULL"`) |
| **`EVENT_AUDIO_PLAY`**           | `String` (Filename: `"crunch.wav"`, `"click.wav"`)                | `Float` (Volume: `0.0` to `1.0`)           | `null`                   | `null`                                             |