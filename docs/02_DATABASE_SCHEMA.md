# Database Schema

## How to View

1. Open [dbdiagram.io](https://dbdiagram.io)
2. Copy contents of `docs/02_DATABASE_SCHEMA.dbml`
3. Paste into the editor

---

## Quick Reference

### Encrypted Fields (GDPR)
| Model | Field |
|---|---|
| User | `phone`, `whatsapp` |
| Request | `identity_card`, `passport` |

### File Attachments (Active Storage, local disk)
| Model | Name | Type |
|---|---|---|
| Request | `application` | has_one_attached |
| Request | `originals` | has_many_attached |
| Request | `documents` | has_many_attached |
| Message | `attachments` | has_many_attached |

Max 10 MB per file. Stored locally via Active Storage (no S3).

### Seeds
```ruby
%w[super_admin coordinator teacher student family].each { |r| Role.find_or_create_by!(name: r) }
```
